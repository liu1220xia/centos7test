#!/bin/env python
#coding:utf8
# Author:liuyang
# create time:2017/8/17

from flask import request,render_template,redirect,session
from . import app
from db import *
import sys
import json
import time
reload(sys)
sys.setdefaultencoding('utf8')


# user表
field = ['id','username','password','age','phone','email','role'] 

# 主页面
@app.route('/')
@app.route('/index/')
def index():
	if not session:
		return redirect('/login')
	data={'username':session['username']}
	print data
	result = getone('user',field,data)
	print result
	return render_template('index.html',result=result['msg'])

# 用户注册
@app.route('/registor/',methods=['POST','GET'])
def registor():
	if request.method == 'POST':
		field = ['username','password','age','phone','email','role']
		data = {k:v[0] for k,v in dict(request.form).items()}
		print data
		result = insert('user',field,data)
		print result
		if result['code'] == 0:
			return redirect('/login/')
		else:
			return render_template('registor.html',result=result)
	return render_template('registor.html')

# 用户登录
@app.route('/login/',methods=['POST','GET'])
def login():
	if request.method == 'POST':
		data = {k:v[0] for k,v in dict(request.form).items()}
		print data
		result = getone('user',field,data)
		print result
		if result['code'] ==0:
			if result['msg']['password'] == data['password']:
				session['username'] = data['username']
				session['role'] = result['msg']['role']
			else:
				result['code']=1,
				result['errmsg']='wrong passwd'
			print session
		else:
			result['errmsg']='user is not exsit'
		return json.dumps(result)
	return render_template('login.html')

# 用户登录界面,普通用户只能看到个人信息，管理员可以看到用户列表
@app.route('/user/')
def user():
    if not session:
	return render_template('login.html')
    username=session['username']
    data={'username':username}
    result=getone('user',field,data)
    print result
    return render_template('index.html',res=session ,result=result['msg'])

# 管理员用户界面 
@app.route('/userlist/')
def userlist():
	if not session:
		return redirect('/login/')
	result = alllist('user',field)
	print result
	return render_template('userlist.html',result=result)

# 显示用户个人信息
@app.route('/userinfo/')
def userinfo():
	if not session:
		return redirect('/login/')
	uid = request.args.get('id')
	data = {'id':uid}
	print data
	result = getone('user',field,data)
	print result
	if result['code'] == 0:
		return json.dumps(result['msg'])

# 更改用户信息
@app.route('/update/',methods=['POST','GET'])
def update():
	if not session:
		return redirect('/login')
	if request.method == 'POST':
		data = {k:v[0] for k,v in dict(request.form).items()}
		result = modify('user',data)
		return json.dumps(result)

# 修改用户密码
@app.route('/updatepasswd/',methods=['POST','GET'])
def updatepasswd():
	if not session:
		return redirect('/login')
	if request.method == "POST":
		data={'password':request.form.get('password'),'id':request.form.get('id')}
		newpasswd=request.form.get('newpasswd')
		result = getone('user',field,data)
		if result['msg']['password'] == data['password']:
			data['password'] = newpasswd	
			result = modify('user',data)
		else:
			result['msg']="旧密码输入错误"
			result['code']=1
		return json.dumps(result)

# 删除用户
@app.route('/delete/')
def delete():
	if not session:
		return redirect('/login')
	uid = request.args.get('id')
	data = {'id':uid}
	result = deleteuser('user',data)
	return json.dumps(result)

# 增加用户信息
@app.route('/adduser/',methods=['GET','POST'])
def adduser():
	if request.method == 'POST':
		field = ['username','password','age','phone','email','role']
		data = {k:v[0] for k,v in dict(request.form).items()}
		result = insert('user',field,data)
		if result['code'] == 0:
			return json.dumps(result)

# 登出系统
@app.route('/logout/')
def logout():
	session.clear()
	return redirect('/login')
