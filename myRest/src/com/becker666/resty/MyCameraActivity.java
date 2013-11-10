package com.becker666.resty;

import java.io.FileOutputStream;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;

public class MyCameraActivity extends Activity {
    private static final int CAMERA_REQUEST = 1888; 
    private ImageView imageView;
    private Button upload;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_my_camera);
        this.imageView = (ImageView)this.findViewById(R.id.imageView1);
        Button photoButton = (Button) this.findViewById(R.id.button1);
        upload = (Button)findViewById(R.id.intent);
        photoButton.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                Intent cameraIntent = new Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE); 
                startActivityForResult(cameraIntent, CAMERA_REQUEST); 
            }
        });
        
       upload.setOnClickListener(new OnClickListener() {
		
		@Override
		public void onClick(View arg0) {
			Intent intent = new Intent(MyCameraActivity.this, main.class);
			intent.putExtra("name", "value");
            startActivity(intent);
			// TODO Auto-generated method stub
			
		}
	});
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {  
        if (requestCode == CAMERA_REQUEST && resultCode == RESULT_OK) {
        	
        	System.out.println(data.getExtras().get("data"));
            Bitmap photo = (Bitmap) data.getExtras().get("data"); 
            imageView.setImageBitmap(photo);
            try {
            	upload.setVisibility(View.VISIBLE);
            	imageView.setVisibility(View.VISIBLE);
                FileOutputStream out = new FileOutputStream("/mnt/sdcard/1.png");
                photo.compress(Bitmap.CompressFormat.PNG, 90, out);
                out.close();
         } catch (Exception e) {
                e.printStackTrace();
         }
        }  
    } 
}