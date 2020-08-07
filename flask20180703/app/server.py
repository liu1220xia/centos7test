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


# +++++++++++++++
# 服务器管理

server_field = ['id','ip','mac','username','password','port','idc','cabinet','brand','cpu','memory','disk','system_type']
# 机柜所有信息
@app.route('/serverlist/')
def serverlist():
	if not session:
		return redirect('/login/')
	result = alllist('server',server_field)
	return render_template('serverlist.html',result=result)

# 显示机柜信息
@app.route('/serverinfo/')
def serverinfo():
	if not session:
		return redirect('/login/')
	serverid = request.args.get('id')
	data = {'id':serverid}
	result = getone('server',server_field,data)
	if result['code'] == 0:
		return json.dumps(result['msg'])

# 添加机柜
@app.route('/serveradd/',methods=['GET','POST'])
def serveradd():
	if request.method == 'POST':
		server_field = ['ip','mac','username','password','port','idc','cabinet','brand','cpu','memory','disk','system_type']
		data = {k:v[0] for k,v in dict(request.form).items()}
		print data
		result = insert('server',server_field,data)
		return json.dumps(result)
	return render_template("serveradd.html")
# 更新机房
@app.route('/serverupdate/',methods=['POST','GET'])
def serverupdate():
	if not session:
		return redirect('/login/')
	if request.method == 'POST':
		data = {k:v[0] for k,v in dict(request.form).items()}
		result = modify('server',data)
		return json.dumps(result)

# 删除服务器信息
@app.route('/serverdelete/')
def serverdelete():
	if not session:
		return redirect('/login/')
	serverid = request.args.get('id')
	data = {'id':serverid}
	result = deleteuser('server',data)
	return json.dumps(result)