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
#  机房管理

idc_field = ['id','name','name_cn','address','adminer','phone']

# 机房所有信息
@app.route('/idclist/')
def idclist():
	if not session:
		return redirect('/login/')
	result = alllist('idc',idc_field)
	return render_template('idclist.html',result=result)

# 显示机房信息
@app.route('/idcinfo/')
def idcinfo():
	if not session:
		return redirect('/login/')
	idcid = request.args.get('id')
	data = {'id':idcid}
	result = getone('idc',idc_field,data)
	if result['code'] == 0:
		return json.dumps(result['msg'])

# 添加机房
@app.route('/idcadd/',methods=['GET','POST'])
def idcadd():
	if request.method == 'POST':
		idc_field = ['name','name_cn','address','adminer','phone']
		data = {k:v[0] for k,v in dict(request.form).items()}
		#print data
		result = insert('idc',idc_field,data)
		return json.dumps(result)

# 更新机房
@app.route('/idcupdate/',methods=['POST','GET'])
def idcupdate():
	if not session:
		return redirect('/login')
	if request.method == 'POST':
		data = {k:v[0] for k,v in dict(request.form).items()}
		result = modify('idc',data)
		return json.dumps(result)

# 删除机房
@app.route('/idcdelete/')
def idcdelete():
	if not session:
		return redirect('/login/')
	idcid = request.args.get('id')
	data = {'id':idcid}
	result = deleteuser('idc',data)
	return json.dumps(result)	
