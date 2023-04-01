package com.kingoapps.photo_route.upload_process

import android.content.Context


class FlutterTask (val appTaskParam: String?, val appTask: (param : String?) -> Unit){

    companion object {
        lateinit var staticTask : (param : String?) -> Unit;
        lateinit var ctx : Context;

        fun initializeTask(task: (param : String?) -> Unit) {
            staticTask = task;
        }

        fun initCtx(cont : Context) {
            ctx = cont;
        }
    }



    fun appTaskExec() : Int {
        this.appTask(this.appTaskParam);
        return 30;
    }
}