
class TimeElement{
  int milliSecond = 0;
  int second = 0;
  int minute = 0;
  int hour = 0;
  TimeElement({required this.hour , required this.minute , required this.second , required this.milliSecond});

  TimeElement.fromCount(int count){
      if ( count != 0  ){
        int a = ( (count ~/ 1000) * 1000 );
        if ( a != 0){
          this.milliSecond = count % a;
          count = count - this.milliSecond;
          this.second = (count ~/ 1000) % 60;
          count = count - this.second * 1000;
          this.minute = (count ~/ (1000 * 60)) % 60;
          count = count - this.minute * 1000 * 60;
          this.hour = count ~/ 1000 ~/ 3600;
        }
      }
  }

  String toString()
  {
    String timeString = this.hour.toString().padLeft(2, "0") + ":" +
        this.minute.toString().padLeft(2, "0") + ":" +
        this.second.toString().padLeft(2, "0") + "." +
        this.milliSecond.toString().padLeft(3, "0");
    return timeString;
  }

}
