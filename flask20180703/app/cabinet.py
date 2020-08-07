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
# 机柜管理

idc_field = ['id','name','name_cn','address','adminer','phone']

cabinet_field = ['id','name','idc_id','u_num','power']

# 机柜所有信息
@app.route('/cabinetlist/')
def cabinetlist():
	if not session:
		return redirect('/login/')
	idcs = alllist('idc',idc_field)['msg']
	idc = {"%s"%idc['id']:idc['name'] for idc in idcs}
	cab = alllist('cabinet',cabinet_field)['msg']
	for c in cab:
		if c['idc_id'] in idc:
			c['idc_id'] = idc[c['idc_id']]
	return render_template('cabinetlist.html',result=cab,idc=idcs)

# 显示机柜信息
@app.route('/cabinetinfo/')
def cabinetinfo():
	if not session:
		return redirect('/login/')
	cabinetid = request.args.get('id')
	data = {'id':cabinetid}
	result = getone('cabinet',cabinet_field,data)
	if result['code'] == 0:
		return json.dumps(result['msg'])

# 添加机柜
@app.route('/cabinetadd/',methods=['GET','POST'])
def cabinetadd():
	if request.method == 'POST':
		cabinet_field = ['name','idc_id','u_num','power']
		data = {k:v[0] for k,v in dict(request.form).items()}
		result = insert('cabinet',cabinet_field,data)
		return json.dumps(result)

# 更新机房
@app.route('/cabinetupdate/',methods=['POST','GET'])
def cabinetupdate():
	if not session:
		return redirect('/login/')
	if request.method == 'POST':
		data = {k:v[0] for k,v in dict(request.form).items()}
		result = modify('cabinet',data)
		return json.dumps(result)

# 删除机房
@app.route('/cabinetdelete/')
def cabinetdelete():
	if not session:
		return redirect('/login/')
	cabinetid = request.args.get('id')
	data = {'id':cabinetid}
	result = deleteuser('cabinet',data)
	#print result 
	return json.dumps(result)

