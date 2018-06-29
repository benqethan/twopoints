package com.topsolution.twopoints;

import android.os.Bundle;
//import android.support.multidex.MultiDex;
import android.content.Context;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
// https://stackoverflow.com/questions/37312103/unable-to-get-provider-com-google-firebase-provider-firebaseinitprovider
//  @Override
//  protected void attachBaseContext(Context context) {
//    super.attachBaseContext(context);
//    MultiDex.install(this);
//  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
  }
}
