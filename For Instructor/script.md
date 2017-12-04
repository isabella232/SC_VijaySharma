## Introduction

Hey what's up everybody, this is Ray. In today's screencast, I'm going to introduce you to a really cool iOS framework called ReplayKit.

ReplayKit records the screen and audio of your application. You can also add your own voice commentary or add your expressions using the the front facing camera to make your recordings personal or provide extra context. It allows your users to play back, scrub and trim their recordings and finally share the recordings to their favorite social networks and video streaming sites. ReplayKit generates high-quality HD recordings that will look great on TV's, websites and mobile devices.

Although available in iOS 9, ReplayKit has added some great APIs in both iOS 10 and 11, allowing developers to live broadcast their recordings to service providers like Twitch or YouTube. Uncharacteristically, ReplayKit doesn't work in the iOS Simulator, so everything you'll see here will be shown on device.

In this screencast, we'll be adding support for ReplayKit in the zombie/brain tic tac toe thriller, originally featured in the [GameplayKit: Artificial Intelligence](https://www.raywenderlich.com/146407/gameplaykit-tutorial-artificial-intelligence) tutorial. Thanks to Ryan Ackermann who originally wrote the tutorial.

We'd also like to thank Vijay Sharma for putting together the materials for this screencast. If you like the screencast, give them both a follow on twitter.

Adding ReplayKit to your app is super easy, so let's dive in.

## Demo 1

In this demo, we're using an app written using SpriteKit, but ReplayKit can be used with apps written purely in UIKit.

You'll start by importing ReplayKit into our project by adding the following header to your Scene.

```
import ReplayKit
```

We've already added a button to start a recording, and a method to handle the touch event.   

```
fileprivate func processTouchRecord() {
```

In order to start recording using ReplayKit, in the body of the method, we'll first get a handle to the shared `RPScreenRecorder` object.

```
  let recorder = RPScreenRecorder.shared()
```

We'll call `startRecording` passing in a callback.

```
recorder.startRecording { (error) in
```
    
In the callback  If there's an error, we'll just print that to the console. 

```
guard error == nil else {
  print("Failed to start recording")
  return
}
```

Otherwise, we'll update the state of the record button so that users know they're currently recording themselves.

```
    self.recordButton.texture = SKTexture(imageNamed:"stop")
  }
}
```

And that's all it takes to record your app using ReplayKit. Now you might be tempted to build and run, but before you do that, let's quickly see what's going on under the hood

## Interlude 1

[slide 01]

When your app calls `startRecording`, `RPScreenRecorder` speaks with the ReplayKit daemon running in the OS. This daemon will capture your screen into a video recording and store it in file only accessible to the daemon. This daemon uses low level video and audio APIs to capture the video to keep performance impact on your app very low. ReplayKit will also avoid recording the system UI, which means any notifications that your user might get while recording won't show up in the final movie.

Next let's give your users the ability to stop the recording and optionally edit and share it.

## Demo 2


In the same method where you call `startRecording`, you can use `RPScreenRecorder`'s' `isRecording` property to determine if we're currently recording, and stop the recording accordingly.

```
if !recorder.isRecording {
  recorder.startRecording { ... }
} else {
  recorder.stopRecording { ... }
}
```

To stop a recording, you have to call the plainly named method `stopRecording`. This is slight different from `startRecording`, in that it returns in the callback, an instance of `RPPreviewViewController`.

```
  recorder.stopRecording(handler: { (previewController, error) in
    guard error == nil else {
      print("Failed to stop recording")
      return
    }
```

The `RPPreviewViewController` allows your users to scrub, edit and share their video recordings to the world. They can also save the recording to their photos, or discard it entirely.

```
previewController?.previewControllerDelegate = self
self.viewController.present(previewController!, animated: true)
self.recordButton.texture = SKTexture(imageNamed:"record")
  })

```

If we want to know when the user is done interacting with the `RPPreviewViewController`, you'll have to conform the `RPPreviewViewControllerDelegate` protocol.

```
extension GameScene: RPPreviewViewControllerDelegate {
```

Here, we'll implement the `previewControllerDidFinish` method, and simply dismiss the controller, being sure to animate it, because... well, animations are fun!

```
func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
		viewController.dismiss(animated: true)
	}
}
```

Build and run, and tap the record button. You'll first get a dialog asking if you want to give the app permission to record. This User consent prompt will be displayed every time you call `startRecording`, but once the user has accepted it, it will not be shown again for another eight minutes. Why 8 minutes? Your guess is as good as mine! In any case, your users now have control over what they'd like to include in their recordings. When you're done, tap the stop button, and you should see a new view controller gracefully slide into view. Feel free to playback your gameplay and share your wins with all your friends and family.

## Interlude 2

That's all you really need to get recoding included in your app.

[slide 02]

Diving just below the surface we can see when `stopRecording` is called, `RPScreenRecorder` tells the ReplayKit daemon running in the OS to return a view controller, which itself contains the recording. ReplayKit does provide other APIs that give you direct access to the image or audio samples, but we'll have to take a look at those another day.

Although recording just the screen can be useful in its own way, it can be fun to include your own reaction to gameplay as part of the recording. In the next section, we'll add the front facing camera to the recording.

## Demo 3

Since you'll need access to the camera for this part of the demo, you'll need to add an entry in the `Info.plist` with the `NSCameraUsageDescription` key, and any text description you want to show your users as its value.

```
<key>NSCameraUsageDescription</key>
<string>This app would like access the front facing camera while recording gameplay.</string>
```

Next you'll have to ask for permission from the user to use the camera. You'll have to do that just before you call `startRecording`, which makes the text you added to the `Info.plist` all the more important. Just before `startRecording`, add the line

```
recorder.isCameraEnabled = true
```

Inside the callback `startRecording`, you can use this same property to check if your app has permission to use the camera.

```
if (recorder.isCameraEnabled) {
```

You'll use this property to hide or show the camera button, removing the ability entirely, in the event your user doesn't want your app to have access to the camera.

```
self.cameraButton.isHidden = false
}
```

You'll also use this opportunity to update the state of your camera button so it's obvious what the button can do.

```
self.cameraButton.texture = SKTexture(imageNamed:"camera")
```

Next, you'll handle touches on this button to hide or show the camera.

```
fileprivate func processTouchCamera() {
  let recorder = RPScreenRecorder.shared()
```

  You'll safely ignore any button presses if you're already recording
  
```
  guard recorder.isRecording else {
    return
  }
```

`RPScreenRecorder` provides a convenient `recorder.cameraPreviewView` property which returns a `UIView` instance of the front facing camera which you'll keep a reference to.

```
  if let cameraView = self.cameraView {
```
    
If you're currently holding an instance of the view, you can assume that the user wants to remove the camera from the recording, and you'll release a reference to the view.

```
    cameraView.removeFromSuperview()
    self.cameraView =  nil
```

You'll also update the state of the camera button so it's clear what the user will expect the next time they tap it.

```
    self.cameraButton.texture = SKTexture(imageNamed:"camera")
  } else {
```  
  
You can add this view directly into your view hierarchy. You'll also hold onto an instance of the view so you can remove it from the hierarchy so the user can toggle between hiding and showing their face in the recording.

If you're currently not holding an instance of the camera view, you can get a reference from `RPScreenRecorder`.

```
self.cameraView = recorder.cameraPreviewView
if let cameraView = self.cameraView {
```

You'll size the view to something that will reasonably fit with your app

```
cameraView.frame = cameraFrame
```

And you'll add the view into the view hierarchy

```
self.viewController.view.addSubview(cameraView)
```
      
You'll also update the state of the camera button so it'll be obvious to your users that tapping it again will remove the camera from the recording

```
      self.cameraButton.texture = SKTexture(imageNamed:"camera_stop")
    }
  }
}
```

Be sure to also remove the view when the user stops the recording.

```
self.cameraView?.removeFromSuperview()
self.cameraView = nil
```

And finally update the state of the camera button so it's back to its initial state

```
self.cameraButton.texture = SKTexture(imageNamed:"camera")
self.cameraButton.isHidden = true
```

Build and run, start your recording, and tap that camera button. Now you can show the world your steely focused look when you win at tic-tac-toe.

## Closing

Alright, that's everything I'd like to cover in this screencast.

At this point, you should understand how to quickly allow users to record their app's screen and share it.

There's a lot more to ReplayKit - including the ability to share your screen directly to a live streaming service or capturing the individual video and audio samples in your own app.

If you find yourself stuck or forgot to how to use replay kit, just replay this video to get yourself started anew. No kit required. 

For more screencasts and video courses about iOS development, keep coming back to raywenderlich.com. Cheers!  
