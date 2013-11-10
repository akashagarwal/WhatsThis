package com.becker666.resty;


import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import oauth.signpost.OAuth;
import oauth.signpost.commonshttp.CommonsHttpOAuthConsumer;
import oauth.signpost.commonshttp.CommonsHttpOAuthProvider;
import oauth.signpost.http.HttpResponse;

import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpEntityEnclosingRequestBase;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.FileEntity;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONArray;
import org.json.JSONObject;


import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.annotation.TargetApi;
import android.app.Activity;

import android.content.Intent;
import android.content.SharedPreferences;


import android.graphics.Paint;

import android.graphics.Rect;
import android.graphics.Paint.FontMetrics;

import android.net.Uri;
import android.os.Build;
import android.os.Bundle;

import android.util.Log;

import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

public class main extends Activity {


	private static EditText myContents;
	private static EditText fName;  
	private View mRegisterFormView;
    private View mRegisterStatusView;

	// need to request this
	String DropB_key="request this From DropBox";
	String DropB_secret="request this From DropBox";

	// from dropB API
	String  request_url = "https://api.dropbox.com/1/oauth/request_token";
	String  authorization_url = "https://www.dropbox.com/1/oauth/authorize";
	String  access_url ="https://api.dropbox.com/1/oauth/access_token";

	// to come nback to our App after user authorises
	String  callBack_url ="myRest://myStep.com";   

	String MY_PREFS_STR ="myRes_settings";

	String result = "";  
	final String tag = "Your Logcat tag: "; 


	private static CommonsHttpOAuthConsumer consumer;
	private static CommonsHttpOAuthProvider provider ;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.testy); 
		setTitle("REST API ");
		


		myContents = (EditText) findViewById(R.id.fContents);
		fName = (EditText) findViewById(R.id.fName);

		final Button btnSend = (Button) findViewById(R.id.cmdSend);
        mRegisterStatusView = findViewById(R.id.register_status);

		//btnSend.setOnClickListener(new OnClickListener() 
		//{
		//public void onClick(View v) 
		//{  
        
		if(Globals.flag==0)
		{
			Toast.makeText(getApplicationContext(), "Starting a restful call ....",
					Toast.LENGTH_SHORT).show();

			setUpAuthorization();
			Globals.flag=1;
		}


		//} // onclick
		//});   //btnsebdnclick



		// onresume is the same as a change of orinetation
		if (savedInstanceState != null)
		{

			String fname =  savedInstanceState.getString("cur_fname");
			if( fname != null)
				fName.setText( fname);

			String fcontents =  savedInstanceState.getString("cur_fcontents");
			if( fcontents != null)
				myContents.setText( fcontents);

		}

	} // --- end of onCreate ---





	public void setUpAuthorization()
	{  

		// Q&D save vals so they r handy when it resumes
		SharedPreferences ll_preferences = getSharedPreferences(MY_PREFS_STR, MODE_PRIVATE);
		final SharedPreferences.Editor ll_prefs_editor = ll_preferences.edit();

		ll_prefs_editor.putString("cur_fname", fName.getText() + ""); 
		ll_prefs_editor.putString("cur_fcontents", myContents.getText() + ""); 
		ll_prefs_editor.commit();



		// ask authorization to request the user
		consumer = new CommonsHttpOAuthConsumer(
				"ulxnvd0w309317v", "rx2ekr750fgae3g");

		provider = new CommonsHttpOAuthProvider(
				request_url, access_url, authorization_url); 

		// we r good not let's ask the user's permission
		try
		{
			String authURL = provider.retrieveRequestToken(
					consumer, callBack_url);


			Intent intent2 = new Intent(Intent.ACTION_VIEW);

			intent2.setData( Uri.parse(authURL) );
			startActivity(intent2);



		}catch (Exception e)
		{}


	} // end setUpAuthorization()  

	/**
	 * Shows the progress UI and hides the login form.
	 */
	@TargetApi(Build.VERSION_CODES.HONEYCOMB_MR2)
	private void showProgress(final boolean show) {
		// On Honeycomb MR2 we have the ViewPropertyAnimator APIs, which allow
		// for very easy animations. If available, use these APIs to fade-in
		// the progress spinner.
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB_MR2) {
			int shortAnimTime = getResources().getInteger(
					android.R.integer.config_shortAnimTime);

			mRegisterStatusView.setVisibility(View.VISIBLE);
			mRegisterStatusView.animate().setDuration(shortAnimTime)
			.alpha(show ? 1 : 0)
			.setListener(new AnimatorListenerAdapter() {
				@Override
				public void onAnimationEnd(Animator animation) {
					mRegisterStatusView.setVisibility(show ? View.VISIBLE
							: View.GONE);
				}
			});

			mRegisterFormView.setVisibility(View.VISIBLE);
			mRegisterFormView.animate().setDuration(shortAnimTime)
			.alpha(show ? 0 : 1)
			.setListener(new AnimatorListenerAdapter() {
				@Override
				public void onAnimationEnd(Animator animation) {
					mRegisterFormView.setVisibility(show ? View.GONE
							: View.VISIBLE);
				}
			});
		} else {
			// The ViewPropertyAnimator APIs are not available, so simply show
			// and hide the relevant UI components.
			mRegisterStatusView.setVisibility(show ? View.VISIBLE : View.GONE);
			mRegisterFormView.setVisibility(show ? View.GONE : View.VISIBLE);
		}
	}

	@Override
	public void onResume() 
	{
		// upon confirmation the call back will come to here.
		super.onResume();



		Uri uri = this.getIntent().getData();





		// so it is coming back from the auth, catch it when it comes to our dummy URL
		if( uri != null)
		{
			// Q&D grab vals  before we left
			SharedPreferences ll_preferences = getSharedPreferences(MY_PREFS_STR, MODE_PRIVATE);

			String str = ll_preferences.getString("cur_fname", "");
			if(str != null )
				fName.setText(str); 
			str = ll_preferences.getString("cur_fcontents", "");
			if(str != null )
				myContents.setText(str); 




			// now let's do the real stuff
			if( uri.getHost().equals("myStep.com"))
			{
				//grab the tokens
				String parms = uri.getEncodedQuery();

				// perfomr the write thru

				try {

					// grab the token/secret items to carry on
					String verifier = uri.getQueryParameter(OAuth.OAUTH_VERIFIER);

					provider.retrieveAccessToken(consumer, verifier);
					String ACCESS_KEY = consumer.getToken();
					String ACCESS_SECRET = consumer.getTokenSecret();

					Log.d("OAuth Dropbox", ACCESS_KEY);
					Log.d("OAuth Dropbox", ACCESS_SECRET);

					// ok so we re good now to query DropB




					// let's get users basic info as a check we r good
					consumer.setTokenWithSecret(ACCESS_KEY, ACCESS_SECRET);

					String uRL_file_list_req="https://api.dropbox.com/1/account/info";
					HttpClient httpclient = new DefaultHttpClient();  
					HttpGet request = new HttpGet(uRL_file_list_req );  

					consumer.sign(request);


					ResponseHandler<String> handler = new BasicResponseHandler();  
					try {  
						result = httpclient.execute(request, handler);  
					} catch (ClientProtocolException e) {  
						e.printStackTrace();  
						Toast.makeText(getApplicationContext(), "Protocol failure uploading the file",
								Toast.LENGTH_SHORT).show();
						return;
					} catch (IOException e) {  
						e.printStackTrace();
						Log.e("******",Log.getStackTraceString(e)); 
						Toast.makeText(getApplicationContext(), "IO failure uploading the file",
								Toast.LENGTH_SHORT).show();
						return;
					}  
					// httpclient.getConnectionManager().shutdown();  
					Log.i(tag, result);  

					JSONObject json_data = new JSONObject(result);
					JSONArray nameArray = json_data.names();
					JSONArray valArray = json_data.toJSONArray(nameArray);

					Toast.makeText(getApplicationContext(), "DropBox confirmation:"+ nameArray.getString(2),
							Toast.LENGTH_SHORT).show();





					// last but not least let's upload a file
					// default parm is overwrite so we keep it simple
					String textStr = myContents.getText() + "";  
					String fileName = fName.getText() + "";  


					uRL_file_list_req="https://api-content.dropbox.com/1/files_put/"  + "sandbox/" + fileName ; //+ "?param=val" ;

					consumer.setTokenWithSecret(ACCESS_KEY, ACCESS_SECRET);


					HttpPost request3 = new HttpPost(uRL_file_list_req );  


					//request3.addHeader("Content-Type", "text/plain"); 
					//request3.setEntity(new StringEntity(textStr)); 

					String filepath = "/mnt/sdcard/1.png";
					//to send an image file -- if needed
					File file = new File(filepath); 
					FileEntity fileentity; 
					fileentity = new FileEntity(file,"image/jpeg"); 
					fileentity.setChunked(true);
					request3.addHeader("Content-Type", "image/jpeg");
					request3.setEntity(fileentity);




					consumer.sign(request3);


					result="";
					try {  
						result = httpclient.execute(request3, handler);  
					} catch (ClientProtocolException e) {  
						e.printStackTrace();  
						Log.e("$$$$$$$",Log.getStackTraceString(e));
						Toast.makeText(getApplicationContext(), "Protocol failure uploading the file",
								Toast.LENGTH_SHORT).show();
						return;

					} catch (IOException e) 
					{  
						e.printStackTrace();
						Log.e("******",Log.getStackTraceString(e)); 
						Toast.makeText(getApplicationContext(), "IO failure uploading the file",
								Toast.LENGTH_SHORT).show();
						return;
					}  

					// parse out the data
					json_data = new JSONObject(result);
					nameArray = json_data.names();
					valArray = json_data.toJSONArray(nameArray);

					Toast.makeText(getApplicationContext(), "Succes!! - " + valArray.getString(7) + " " + valArray.getString(10),
							Toast.LENGTH_SHORT).show();


					String public_url = 
							"http://dl.dropboxusercontent.com/u/82437225/win.jpg" ;
					String reverse = "http://www.google.com/searchbyimage?&image_url=" + public_url ;
					Intent intent2 = new Intent(Intent.ACTION_VIEW); 

					intent2.setData( Uri.parse(reverse) );          
					startActivity(intent2);                         
					httpclient.getConnectionManager().shutdown(); 


				} 
				catch(Exception e)
				{}

			}
		}


	}  // -- end of onResume---





	// need the width of the labels
	private static int getCurTextLengthInPixels(Paint this_paint, String this_text) {
		FontMetrics tp = this_paint.getFontMetrics();
		Rect rect = new Rect();
		this_paint.getTextBounds(this_text, 0, this_text.length(), rect);
		return rect.width();
	} // --- end of getCurTextLengthInPixels  ---





}  // -- end of CLASS ---