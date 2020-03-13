import 'dart:async';

mixin SignInValidators {
  var emailValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink) {
      if(email.contains("@")) {
        sink.add(email);
      } else {
        sink.addError("Email address is not valid");
      }
    }
  );

  var passwordValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (password, sink) {
      if(password.length > 7) {
        sink.add(password);
      } else {
        sink.addError("Password is invalid");
      }
    }
  );
}