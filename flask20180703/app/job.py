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
# 工单管理

job_field = ['id','apply_type','apply_desc','apply_persion','deal_persion','apply_date','deal_time','deal_desc','status']

# 工单列表主要申请的工单
@app.route('/joblist/')
def joblist():
	if not session.get('username',None):
		return redirect('/login/')
	where = {'status':['0','1']}
	result = alllist('job',job_field)
	return render_template('joblist.html',result=result)

# 申请工单	
@app.route('/jobadd/',methods=['GET','POST'])
def jobadd():
	if not session.get('username',None):
		return redirect('/login/')
	if request.method == 'POST':
		job_field = ['apply_date','apply_type','apply_desc','status','apply_persion']
		data = {k:v[0] for k,v in dict(request.form).items()}
		if not data['apply_desc']:
			return json.dumps({'code':1,'msg':'job desc not null'})
		data['apply_date'] = time.strftime('%Y-%m-%d %H:%M')
		data['status'],data['apply_persion'] = 0,session['username']
		result = insert('job',job_field,data)
		return json.dumps(result)
	else:
		return render_template('jobadd.html',result = session)

# 工单处理
@app.route('/jobupdate/',methods=['GET','POST'])
def jobupdate():
	if not session.get('username',None):
		return redirect('/login')
	name = session['username']
	if request.method == "POST":
		data = {k:v[0] for k,v in dict(request.form).items()}
		data['status'] = 2
		data['deal_persion'] = name
		data['deal_time'] = time.strftime('%Y-%m-%d %H:%M')
		print data
		result = modify('job',data)
	else:
		id =request.args.get('id')
		data = {'id':id,'status':1,'deal_persion':name,'deal_time':time.strftime('%Y-%m-%d %H:%M')}
		result = modify('job',data)
	return json.dumps(result)

# 历史工单显示所有工单信息
@app.route('/jobhistory/')
def jobhistory():
	if not session:
		return redirect('/login/')
	result = alllist('job',job_field)
	print result
	return render_template('jobhistory.html',result=result)

# 工单详情
@app.route('/jobdetail/')
def jobdetail():
	if not session:
		return redirect('/login/')
	jobid = request.args.get('id')
	data = {'id':jobid}
	result = getone('job',job_field,data)
	result['msg']['apply_date']=str(result['msg']['apply_date'])
	result['msg']['deal_time']=str(result['msg']['deal_time'])
	print result
	if result['code'] == 0:
		return json.dumps(result)
