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
//	BackThread thread = new BackThread(); // ��� ��¿� ����� ������
	
	protected static final int THREAD_FLAGS_STOP=0; // counter ����
	protected static final int THREAD_FLAGS_START=1; // counter ����
	protected static final int THREAD_FLAGS_SET_DISABLE=2; // segment �� �о����
	protected static final int THREAD_FLAGS_SET_ENABLE=3; // segment�� ���� ���
	
	protected static final int DIALOG_INPUT_MESSAGE=1;
	protected static final int DIALOG_START_MESSAGE=2;
	int flag = -1; // ������ ����� ������ �˸��� �÷���
	boolean stop = false; // ������ ����� ���Ḧ �˸��� �÷���
	int count = 0; // ����� �Է��� �޴� ����
	
	Handler handler;
	EditText segVal;
	TextView flagView;
	
	//TODO JNI library
	public native int SegmentControl(int value);      
	public native int SegmentIOControl(int value);
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        System.loadLibrary("7segment"); // JNI�� �ۼ��� ���̺귯���� �ε�(lib, .so�� �����ȴ�)
        
        // TODO Thread start
//        thread.setDaemon(true);
//        thread.start();
        
        // view�� ��ҵ� ����
        segVal = (EditText) findViewById(R.id.segVal); // segment�� ���ų� �о�� ���� ����
        final Button segSet = (Button) findViewById(R.id.segSet); // segVal�� �ִ� ���� segment�� set
        //final Button clock = (Button) findViewById(R.id.clock);
        final Button cntStart = (Button) findViewById(R.id.cntStart); // counter�� ����
        final Button cntStop = (Button) findViewById(R.id.cntStop); // counter�� ����
        final Button segOff = (Button) findViewById(R.id.segOff); // segment���� ���� off��
        
        flagView = (TextView) findViewById(R.id.flagView);
        
        // segSet button click event �߻� ��
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
        		flag = THREAD_FLAGS_SET_ENABLE; // flag ���� ��ȭ�� �־� ������ �ൿ�� ����
        	}
        }); // segSet button click event ��
        
        // cntStart button click event
        cntStart.setOnClickListener(new Button.OnClickListener(){
        	public void onClick(View v){
        		
        		// segVal > 1 million number, error
        		if(Integer.parseInt(segVal.getText().toString())>999999
        				|| Integer.parseInt(segVal.getText().toString()) < 0){
        			showDialog(DIALOG_INPUT_MESSAGE);
        			return;
        		}
        		
        		flag = THREAD_FLAGS_START;
        	}
        }); // cntStart button click event ��
        
        // cntStop button click event
        cntStop.setOnClickListener(new Button.OnClickListener(){
        	public void onClick(View v){
        		flag = THREAD_FLAGS_STOP;
        	}
        }); // cntStop button click event ��
        
        // segOff button click event
        segOff.setOnClickListener(new Button.OnClickListener(){
        	public void onClick(View v){
        		flag = -1;
        	}
        }); // segOff button click event ��
        
        
        // 0.1�ʸ��� segment�κ��� ���� �о���� handler�� ����� �ʹ�...!
        handler = new Handler() {
        	int cnt = 0;
			public void handleMessage(Message msg) {
				cnt++;
				handler.sendEmptyMessageDelayed(0, 100);
				
				// state display
				switch(flag){
				case THREAD_FLAGS_STOP:
					flagView.setText("STOP");
					break;
					
				case THREAD_FLAGS_SET_ENABLE:
					flagView.setText("SET");
					break;

				case THREAD_FLAGS_START:
					flagView.setText("START");
					break;
				
				case THREAD_FLAGS_SET_DISABLE:
					flagView.setText("SET_D");
					segVal.setText(""+cnt);
					break;
					
				default:
					break;
				}// state display ��
				
				if(flag == THREAD_FLAGS_START) {
					flag = THREAD_FLAGS_SET_DISABLE;
				} else if(flag == THREAD_FLAGS_SET_DISABLE){
					flag = THREAD_FLAGS_START;
				}
			}
		};
		
		handler.sendEmptyMessage(0);
		// timer ��
        
    }
    
    // counter�� ���� ������ ������
    class BackThread extends Thread{
    	public void run(){
    		while(!stop){
    			switch(flag){
    			
    			case THREAD_FLAGS_SET_ENABLE:
    				SegmentIOControl(THREAD_FLAGS_SET_ENABLE); // �ش� ��� ������ �������� ����̽� ����̹����� �˷��ش�
    				// TODO counter�� ���� ����
    				SegmentControl(count);
    				break;
    				
    			case THREAD_FLAGS_START:
    				SegmentIOControl(THREAD_FLAGS_START);
    				// TODO counter�� ���� ��ȣ�� ����
    				break;
    				
    			case THREAD_FLAGS_STOP:
    				SegmentIOControl(THREAD_FLAGS_STOP);
    				// TODO counter�� ���� ��ȣ�� ����
    				break;
    				
    			case THREAD_FLAGS_SET_DISABLE:
    				SegmentIOControl(THREAD_FLAGS_SET_DISABLE);
    				// TODO counter�κ��� ���� �о��
    				break;
    			default:
    				// �ƹ� �ϵ� ���� ����
    				break;
    			}
    		}		
    	}
    }
    
    // Ű ����. BACK ��ư ���� ���α׷� ���� �� �����嵵 ���� ��Ŵ
	public boolean onKeyDown(int keyCode, KeyEvent event){
		if(keyCode == KeyEvent.KEYCODE_BACK){
			flag=-1;
			stop=true;
//			thread.interrupt();
		}
		return super.onKeyDown(keyCode,event);
	}// ������ ���� ��
	
	
	// ���� �Է� ���� �޽��� ó��
	@Override
	protected Dialog onCreateDialog(int id) {
		Dialog d = new Dialog(SegmentActivity.this);
		Window window = d.getWindow();
		
		window.setFlags(WindowManager.LayoutParams.FIRST_APPLICATION_WINDOW
				, WindowManager.LayoutParams.FIRST_APPLICATION_WINDOW);
		
		switch(id){
			case DIALOG_INPUT_MESSAGE:
				d.setTitle("�Է� ������ ������ ���̴� 6�ڱ��� �Դϴ�.");
				d.show();
				return d;
			
			case DIALOG_START_MESSAGE:
				d.setTitle("count �߿��� ���� ������ �� �����ϴ�.");
				d.show();
				return d;
		}
		
		return super.onCreateDialog(id);
	}
}