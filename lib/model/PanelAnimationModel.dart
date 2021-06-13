import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';

class PanelAnimationModel {


  PanelAnimationModel( TickerProvider vsync, {int durationSeconds, Function() onAnimate, Function() onCompleted}){
    this._vsync = vsync;
    this._durationSeconds = durationSeconds;
    this._onAnimate = onAnimate;
    this._onCompleted = onCompleted;

    _initialize();
  }

  TickerProvider _vsync;

  Function() _onAnimate;

  Function() _onCompleted;

  int _durationSeconds;
  
  Animation<double> _animation;
  AnimationController _animationController;
//  double _animationExpansionrate = 0.0;

  get animationValue => _animation == null ? 0.0 : _animation.value;

  get status => _animationController.status;

  get controller => _animationController;

  void _initialize() {

    _animationController = AnimationController( duration: Duration(seconds:_durationSeconds), vsync: _vsync)..addListener(() {
      if ( _onAnimate != null ) {
        _onAnimate();
      }

    //   setState(() {
    //     _animationExpansionrate = _animation.value;
    //   });
    })..addStatusListener((status) {
      print('PanelAnimationModel AnimationController Status:$status');
      if (status == AnimationStatus.completed) {
        if ( _onCompleted != null ) {
          _onCompleted();
        }
      }
      if (status == AnimationStatus.dismissed) {
        if ( _onCompleted != null ) {
          _onCompleted();
        }
      }
      // if (status == AnimationStatus.completed) {
      //   _animationController.reverse();
      // } else if (status == AnimationStatus.dismissed) {
      //   _animationController.forward();
      // }
    });
    _animation = Tween(begin: 0.0, end: 100.0).animate(_animationController);
    //  _animationController.forward();
  }

  void forward(){
    _animationController.forward();
  }

  void restartAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  void dispose(){
    _animationController.dispose();
  }

  void fling({ double velocity = 1.0}){
    _animationController.fling(velocity:velocity);
  }

  void reverse() {
    _animationController.reverse();
  }

  void stop(){
    _animationController.stop();
  }
}