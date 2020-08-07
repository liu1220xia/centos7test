from flask import Flask

app = Flask(__name__)
app.secret_key="daf"

import user,idc,cabinet,server,job,db,utils,config
import ansible_cmd
