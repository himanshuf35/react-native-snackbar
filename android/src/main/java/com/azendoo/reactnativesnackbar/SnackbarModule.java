package com.azendoo.reactnativesnackbar;

import android.graphics.Color;
import android.os.Build;
import android.support.design.widget.Snackbar;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.Gravity;
import android.view.Display;
import android.widget.ImageView;
import android.view.ViewGroup.LayoutParams;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.ScaleDrawable;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SnackbarModule extends ReactContextBaseJavaModule{

    private static final String REACT_NAME = "RNSnackbar";
    private ReactApplicationContext context;
    private List<Snackbar> mActiveSnackbars = new ArrayList<>();

    public SnackbarModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.context = reactContext;
    }

    @Override
    public String getName() {
        return REACT_NAME;
    }

    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();

        constants.put("LENGTH_LONG", Snackbar.LENGTH_LONG);
        constants.put("LENGTH_SHORT", Snackbar.LENGTH_SHORT);
        constants.put("LENGTH_INDEFINITE", Snackbar.LENGTH_INDEFINITE);

        return constants;
    }

    @ReactMethod
    public void show(ReadableMap options, final Callback callback) {
        int duration = options.hasKey("duration") ? options.getInt("duration") : Toast.LENGTH_SHORT;
        int type = options.hasKey("type") ? options.getInt("type") : 1;
        String message = options.hasKey("title") ? options.getString("title") : "";
        LayoutInflater inflater = (LayoutInflater) this.context.getSystemService( Context.LAYOUT_INFLATER_SERVICE );
        View toastview = inflater.inflate(R.layout.custom_toast, (ViewGroup) getCurrentActivity().getWindow().getDecorView().findViewById(R.id.custom_toast_layout));
        Drawable drawable = getCurrentActivity().getResources().getDrawable(R.drawable.toast_box);
        Display display = getCurrentActivity().getWindowManager().getDefaultDisplay();
        int width = display.getWidth();
        int height = display.getHeight();
        drawable.setBounds(0, 0, width - 30, height);
        toastview.setBackground(drawable);
        toastview.setTranslationZ(2.0f);
        TextView toastTextView = (TextView) toastview.findViewById(R.id.custom_toast_text);
        toastTextView.setText(message);
        ImageView image = (ImageView) toastview.findViewById(R.id.custom_toast_image);
        this.setImage(image, type);
        Toast toast = new Toast(this.context);
        toast.setGravity(Gravity.BOTTOM, 0, 24);
        toast.setDuration(Toast.LENGTH_LONG);
        toast.setView(toastview);
        toast.show();
    }

    @ReactMethod
    public void dismiss() {
        for (Snackbar snackbar : mActiveSnackbars) {
            if (snackbar != null) {
                snackbar.dismiss();
            }
        }

        mActiveSnackbars.clear();
    }

    private void setImage(ImageView image, int type) {
        switch(type) {
            case 0: 
                image.setImageResource(R.drawable.success);
                break;
            case 1: 
                image.setImageResource(R.drawable.warning);
                break;
            case 2: 
                image.setImageResource(R.drawable.info);
                break;
            case 3: 
                image.setImageResource(R.drawable.fail);
                break;
        }
    }

    private void displaySnackbar(View view, ReadableMap options, final Callback callback) {
        String title = options.hasKey("title") ? options.getString("title") : "";
        int duration = options.hasKey("duration") ? options.getInt("duration") : Snackbar.LENGTH_SHORT;

        Snackbar snackbar = Snackbar.make(view, title, duration);
        mActiveSnackbars.add(snackbar);

        // Set the background color.
        if (options.hasKey("backgroundColor")) {
            snackbar.getView().setBackgroundColor(options.getInt("backgroundColor"));
        }

        if (options.hasKey("action")) {
            View.OnClickListener onClickListener = new View.OnClickListener() {
                // Prevent double-taps which can lead to a crash.
                boolean callbackWasCalled = false;
                
                @Override
                public void onClick(View v) {
                    if (callbackWasCalled) return;
                    callbackWasCalled = true;

                    callback.invoke();
                }
            };

            ReadableMap actionDetails = options.getMap("action");
            snackbar.setAction(actionDetails.getString("title"), onClickListener);
            snackbar.setActionTextColor(actionDetails.getInt("color"));
        }

        // For older devices, explicitly set the text color; otherwise it may appear dark gray.
        // http://stackoverflow.com/a/31084530/763231
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            View snackbarView = snackbar.getView();
            TextView snackbarText = (TextView) snackbarView.findViewById(android.support.design.R.id.snackbar_text);
            snackbarText.setTextColor(Color.WHITE);
        }

        snackbar.show();
    }

    /**
     * Loop through all child modals and save references to them.
     */
    private ArrayList<View> recursiveLoopChildren(ViewGroup view, ArrayList<View> modals) {
        if (view.getClass().getSimpleName().equalsIgnoreCase("ReactModalHostView")) {
            modals.add(view.getChildAt(0));
        }

        for (int i = view.getChildCount() - 1; i >= 0; i--) {
            final View child = view.getChildAt(i);

            if (child instanceof ViewGroup) {
                recursiveLoopChildren((ViewGroup) child, modals);
            }
        }

        return modals;
    }

}
