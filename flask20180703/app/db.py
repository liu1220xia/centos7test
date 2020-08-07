#!/bin/env python
#coding=utf-8

import MySQLdb as mysql
import config
import utils
import traceback
#conn=mysql.connect(host='127.0.0.1',user='root',passwd='root123',db='reboot15',port=6666,charset='utf8')
conn = mysql.connect(config.host,config.user,config.password,config.db,config.port)
conn.autocommit(True)
cur = conn.cursor()


def insert(table,field,data):
	sql = "insert into %s (%s) values (%s)"%(table,','.join(field),','.join(['"%s"' % data[x] for x in field]))
	print sql
	try:	
		res = cur.execute(sql)
		utils.WriteLog('sql').info("insert:%s" % sql)
		result = {'code':0,'msg':'insert ok'}
	except:
		result = {'code':1,'msg':'insert fail'}
		utils.WriteLog('db').error('Execute %s error:%s' %(sql,traceback.format_exc()))
	return result


def getone(table,field,data):
	if data.has_key('username'):
		sql = 'select * from %s where username="%s";'%(table,data['username'])
	else:
		sql = 'select * from %s where id ="%s"'%(table,data['id'])
	cur.execute(sql)
	try:	
		res = cur.fetchone()
		utils.WriteLog('sql').info("getone:%s" % sql)
		data = {k:res[i] for i,k in enumerate(field)}
		result = {'code':0,'msg':data}
	except:
		utils.WriteLog('db').error('Execute %s error:%s' %(sql,traceback.format_exc()))
		result = {'code':1,'msg':'data is null'}
	return result

def alllist(table,field):
	sql = 'select * from %s;'%(table)
	#utils.WriteLog('sql').info("alllist:%s" % sql)
	cur.execute(sql)
	try:	
		res = cur.fetchall()
		utils.WriteLog('sql').info("alllist:%s" % sql)
		data = [{k:row[i] for i,k in enumerate(field)} for row in res]
		result = {'code':0,'msg':data}
	except:
		utils.WriteLog('db').error('Execute %s error:%s' %(sql,traceback.format_exc()))
		result = {'code':1,'msg':'data is null'}
	return result

def modify(table,data): 
    	conditions = ["%s='%s'" % (k,data[k]) for k in data]
    	sql = "update %s set %s where id=%s;" %(table,','.join(conditions),data['id'])
	try:	
    		res = cur.execute(sql)
		utils.WriteLog('sql').info("modify:%s" % sql)
        	result = {'code':0,'msg':'update ok'}
	except:
		utils.WriteLog('db').error('Execute %s error:%s' %(sql,traceback.format_exc()))
        	result = {'code':1,'msg':'update fail'}
	return result

def deleteuser(table,data):
	sql = 'delete from %s where id="%s";'%(table,data['id'])
	try:	
    		res = cur.execute(sql)
		utils.WriteLog('sql').info("deleteuser:%s" % sql)
		result = {'code':0,'msg':'delete ok'}
	except:
		utils.WriteLog('db').error('Execute %s error:%s' %(sql,traceback.format_exc()))
        	result = {'code':1,'msg':'delete fail'}
	return result

def select(table,data):
	sql='select %s from %s'%(data,table)
	print sql
   	cur.execute(sql)
   	result=cur.fetchall()
   	return result

cur.close
conn.close
