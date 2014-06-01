package com.hanback.segment;

import android.app.Activity;
import android.app.Dialog;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

public class SegmentActivity extends Activity {
    /** Called when the activity is first created. */
	BackThread thread = new BackThread(); // 결과 출력에 사용할 스레드
	
	protected static final int THREAD_FLAGS_STOP=256; // counter 중지
	protected static final int THREAD_FLAGS_START=257; // counter 시작
	protected static final int THREAD_FLAGS_SET_DISABLE=258; // segment 값 읽어오기
	protected static final int THREAD_FLAGS_SET_ENABLE=259; // segment에 값을 출력
	
	protected static final int DIALOG_INPUT_MESSAGE=1;
	protected static final int DIALOG_START_MESSAGE=2;
	int flag = -1; // 스레드 기능의 시작을 알리는 플래그
	boolean stop = false; // 스래드 기능의 종료를 알리는 플래그
	int count = 0; // 사용자 입력을 받는 변수
	int read_count = 0;
	
	Handler handler;
	EditText segVal;
	TextView flagView;
	
	public native int SegmentRead();
	public native int SegmentControl(int value);      
	public native int SegmentIOControl(int value);
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        System.loadLibrary("segcounter"); // JNI로 작성한 라이브러리를 로드(lib, .so는 생략된다)
        
        thread.setDaemon(true);
        thread.start();
        
        // view의 요소들 정의
        segVal = (EditText) findViewById(R.id.segVal); // segment에 쓰거나 읽어올 값을 저장
        final Button segSet = (Button) findViewById(R.id.segSet); // segVal에 있는 값을 segment에 set
        final Button cntStart = (Button) findViewById(R.id.cntStart); // counter를 시작
        final Button cntStop = (Button) findViewById(R.id.cntStop); // counter를 멈춤
        
        flagView = (TextView) findViewById(R.id.flagView);
        
        // segSet button click event 발생 시
        segSet.setOnClickListener(new Button.OnClickListener(){
        	public void onClick(View v){
        		// segVal > 1 million number, error
        		if(Integer.parseInt(segVal.getText().toString())>999999
        				|| Integer.parseInt(segVal.getText().toString()) < 0){
        			showDialog(DIALOG_INPUT_MESSAGE);
        			return;
        		}
        		
        		if(flag == THREAD_FLAGS_START) {
        			showDialog(DIALOG_START_MESSAGE);
        			return;
        		}
        		
        		count = Integer.parseInt(segVal.getText().toString());
        		
        		flag = THREAD_FLAGS_SET_ENABLE; // flag 값에 변화를 주어 스레드 행동을 제어
        		flagView.setText("SET : "+count);
        	}
        }); // segSet button click event 끝
        
        // cntStart button click event
        cntStart.setOnClickListener(new Button.OnClickListener(){
        	public void onClick(View v){
        		flag = THREAD_FLAGS_START;
        	}
        }); // cntStart button click event 끝
        
        // cntStop button click event
        cntStop.setOnClickListener(new Button.OnClickListener(){
        	public void onClick(View v){
        		flag = THREAD_FLAGS_STOP;
        	}
        }); // cntStop button click event 끝

        
        // 0.1초마다 segment로부터 값을 읽어오는 handler를 만들고 싶다...!
        handler = new Handler() {
			public void handleMessage(Message msg) {
				handler.sendEmptyMessageDelayed(0, 1);
				if(flag != THREAD_FLAGS_SET_ENABLE){
					flagView.setText("CURRENT : "+read_count);				
				}
			}
		};
		
		handler.sendEmptyMessage(0);
		// timer 끝
        
    }
    
    // counter에 값을 보내는 스레드
    class BackThread extends Thread{
    	public void run(){
    		while(!stop){
    			switch(flag){
    			
    			case THREAD_FLAGS_SET_ENABLE:
    				SegmentIOControl(THREAD_FLAGS_SET_ENABLE); // 해당 출력 포맷이 무엇인지 디바이스 드라이버에게 알려준다
    				SegmentControl(count);
    				break;
    				
    			case THREAD_FLAGS_START:
    				SegmentIOControl(THREAD_FLAGS_SET_DISABLE);
    				SegmentIOControl(THREAD_FLAGS_START); // 시작 신호
    				break;
    				
    			case THREAD_FLAGS_STOP:
    				SegmentIOControl(THREAD_FLAGS_SET_DISABLE);    				
    				SegmentIOControl(THREAD_FLAGS_STOP); //  counter에 정지 신호를 보냄
    				break;
    				
    			default:
    				// 아무 일도 하지 않음
    				break;
    			}
    			
    			// 값을 읽어옴
    			if(flag != THREAD_FLAGS_SET_ENABLE){
    				read_count = SegmentRead();
    			}
    			
    		}		
    	}
    }

    
    // 키 제어. BACK 버튼 눌려 프로그램 종료 시 스레드도 종료 시킴
	public boolean onKeyDown(int keyCode, KeyEvent event){
		if(keyCode == KeyEvent.KEYCODE_BACK){
			flag=-1;
			stop=true;
			thread.interrupt();
		}
		return super.onKeyDown(keyCode,event);
	}// 스레드 종료 끝
	
	
	// 문자 입력 예외 메시지 처리
	@Override
	protected Dialog onCreateDialog(int id) {
		Dialog d = new Dialog(SegmentActivity.this);
		Window window = d.getWindow();
		
		window.setFlags(WindowManager.LayoutParams.FIRST_APPLICATION_WINDOW
				, WindowManager.LayoutParams.FIRST_APPLICATION_WINDOW);
		
		switch(id){
			case DIALOG_INPUT_MESSAGE:
				d.setTitle("입력 가능한 문자의 길이는 6자까지 입니다.");
				d.show();
				return d;
			
			case DIALOG_START_MESSAGE:
				d.setTitle("count 중에는 값을 변경할 수 없습니다.");
				d.show();
				return d;
		}
		
		return super.onCreateDialog(id);
	}
}