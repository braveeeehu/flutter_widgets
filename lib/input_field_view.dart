import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

enum InputFieldType {
  phone, //手机号码  暂时只做位数限制
  password, //密码  有安全输入选项
  code,// 验证码  后面会有发送验证码选项
  name, //普通输入 名字
  idCard,//身份证号码
}
typedef AsyncCallback = Future<bool> Function();

class InputField extends StatefulWidget {
  //输入框类型
  final InputFieldType type;
  //控制器
  final TextEditingController controller;
  //提示符
  final String placeHolder;
  ///输入框内容改变回调
  final ValueChanged<String> onChanged;

  final AsyncCallback onGetCode;

  final TextInputAction inputAction;

  final bool autoFocus;

  InputField({
    this.type = InputFieldType.phone,
    this.controller,
    this.placeHolder,
    this.onChanged,
    this.onGetCode,
    this.inputAction = TextInputAction.next,
    this.autoFocus = false,
  });

  @override
  InputFieldState createState() => InputFieldState();
}

class InputFieldState extends State<InputField> {

  bool _secure = true;
  bool _codeRequesting = false;
  int _countDownTime = 60;
  Timer _timer;
  bool _offstage = true;

  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    if(widget.controller != null){
      _controller = widget.controller;
    }
    return Container(
        width: double.infinity,
        height: 93, //数字是由注册页面两个输入框间距加本身高度计算得出  使用的时候不需要再考虑控件间隔
        child:Stack(
          children: <Widget>[
            //上方提示
            Container(margin: EdgeInsets.only(top: 0),height: 22,
                child:Offstage(offstage: _offstage,
                    child:Text(widget.placeHolder??'',style: _tipTextStyle())),padding: EdgeInsets.only(top: 5)),
            //输入框
            Container(margin: EdgeInsets.only(top: 20),padding: EdgeInsets.only(top: 11),height: 46,
                child: _textField()),
            //输入线
            Container(margin: EdgeInsets.only(top: 68),
                color: Colors.blue,height: 1),
          ],
        )
    );
  }

  Widget _textField(){
    switch(widget.type) {
      case InputFieldType.code:{
        return _codeInputField();
      }
      case InputFieldType.password:{
        return _passwordInputField();
      }
      case InputFieldType.phone:{
        return _phoneInputField();
      }
      case InputFieldType.name:{
        return _nameInputField();
      }
      case InputFieldType.idCard:{
        return _idCardInputField();
      }
      default:
        return _phoneInputField();
    }
  }

  TextField _commonTextField(TextInputType keyBoardType,List<TextInputFormatter> inputFormatters){
    return TextField(
      autofocus: widget.autoFocus,
      cursorWidth: 1,
      controller: _controller,
      enableInteractiveSelection: false,
      onChanged: (String str){
        setState(() {
          _offstage = str.length > 0 ? false : true;
        });
        widget.onChanged(str);
      },
      maxLengthEnforced: true,
      inputFormatters: inputFormatters,
      keyboardType: keyBoardType,
      keyboardAppearance: Brightness.light,
      style: _mainTextStyle(),
      textInputAction: widget.inputAction,
      decoration: _inputDecoration(),
      obscureText: widget.type == InputFieldType.password ? _secure : false,
    );
  }

  Widget _nameInputField(){
    return _commonTextField(TextInputType.text, null);
  }

  Widget _idCardInputField(){
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Container(margin: EdgeInsets.only(right: 24),
            child:_commonTextField(TextInputType.text,
                [WhitelistingTextInputFormatter(RegExp("[0-9xX]")),LengthLimitingTextInputFormatter(18)])),
        _positionedClearButton(0),
      ],
    );
  }

  Widget _phoneInputField(){
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Container(margin: EdgeInsets.only(right: 24),child:_commonTextField(TextInputType.number, [
          WhitelistingTextInputFormatter(RegExp("[0-9 ]")),
          LengthLimitingTextInputFormatter(11)
        ])),
        _positionedClearButton(0),
      ],
    );
  }

  Widget _passwordInputField(){
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Container(margin: EdgeInsets.only(right: 12),child: _commonTextField(TextInputType.text, null),),
        _positionedClearButton(38),
        Positioned(child: _secureButton(),
          width: 22,
          height: 22,
          right: 0,
          bottom: 11,
        )
      ],
    );
  }

  Widget _codeInputField(){
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Positioned(
            child: _commonTextField(TextInputType.number, null)
        ),
        Positioned(
            top: 12,
            right: 0,
            height: 22,
            child: FlatButton(
              onPressed: _codeRequesting ? null : () {
                if(_codeRequesting) return;
                _codeRequesting = true;
                widget.onGetCode().then((bool success){
                  setState(() {
                    _codeRequesting = false;
                    if(success)  _startTimer();
                  });
                });
              },
              child: _codeRequestText(),
            ))
      ],
    );
  }

  Text _codeRequestText(){
    if(_codeRequesting) {
      return Text('${_countDownTime}S后可重发',style: TextStyle(fontSize: 14,color: Colors.black38));
    }else {
      return Text('获取验证码',style: TextStyle(fontSize: 14,color: Colors.black));
    }
  }

  void _startTimer(){
    _timer = Timer.periodic(Duration(seconds: 1), (timer){
      setState(() {
        if (_countDownTime < 1) {
          _timer.cancel();
          _codeRequesting = false;
          _countDownTime = 60;
        } else {
          _countDownTime = _countDownTime - 1;
        }
      });
    });
  }

  Positioned _positionedClearButton(double right){
    return Positioned(
      width: 22,
      height: 22,
      bottom: 11,
      right: right,
      child: Offstage(
        offstage: _offstage,
        child: FlatButton(onPressed: (){
          _controller.text = '';
          setState(() {
            _offstage = true;
          });
        },
            child: Icon(Icons.cancel),
            padding: EdgeInsets.all(0)),
      ),
    );
  }

  Widget _secureButton(){
    return FlatButton(onPressed: (){
      setState(() {
        _secure = !_secure;
      });
    },
      child: _secureImage(),
      padding: EdgeInsets.all(0),
    );
  }

  Widget _secureImage(){
    if(_secure){
      return Icon(Icons.visibility_off);
    }else {
      return Icon(Icons.visibility);
    }
  }

  TextStyle _tipTextStyle(){
    return TextStyle(
      color: Colors.black38,
      fontSize: 14,
    );
  }

  TextStyle _mainTextStyle(){
    return TextStyle(
      color: Colors.black,
      fontSize: 16,
      height: 1.2,//通过修改该高度改变单纯输入框高度
    );
  }

  InputDecoration _inputDecoration(){
    return InputDecoration(
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      hintText: widget.placeHolder,
      hintStyle: _tipTextStyle(),
      contentPadding: widget.type == InputFieldType.password
          ? EdgeInsets.only(bottom : 5.0,right: 50)
          : EdgeInsets.only(bottom : 5.0) ,
    );
  }
  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }
}



