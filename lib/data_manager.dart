import 'package:shared_preferences/shared_preferences.dart';

class DataManager{
  SharedPreferences preferences;

/*
  DataManager() {
  }
*/

  build() async{
    preferences = await SharedPreferences.getInstance();
  }

  dynamic get(String key, def){
    return this.preferences.get(key) ?? def;
  }

  bool set(String key, value){
    return this.put(key, value);
  }

  bool put(String key, value){
    if(value is String) {
      this.preferences.setString(key, value);
    }else if(value is int){
      this.preferences.setInt(key, value);
    }else if(value is bool){
      this.preferences.setBool(key, value);
    }else if(value is double){
      this.preferences.setDouble(key, value);
    }else if(value is List<String>){
      this.preferences.setStringList(key, value);
    }else{
      return false;
    }
    return true;
  }

  Future<bool> remove(String key){
    return this.preferences.remove(key);
  }

}