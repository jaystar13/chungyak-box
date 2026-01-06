package com.jaystar.chungyakbox

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import com.navercorp.nid.NidOAuth
import com.navercorp.nid.oauth.util.NidOAuthCallback

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.chungyakbox/auth"
    private var channelResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Naver SDK 초기화
        val naverClientId = getString(R.string.naver_client_id)
        val naverClientSecret = getString(R.string.naver_client_secret)
        val naverClientName = getString(R.string.naver_client_name)

        NidOAuth.initialize(this, naverClientId, naverClientSecret, naverClientName)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            channelResult = result
            when (call.method) {
                "signInWithNaver" -> naverLogin()
                "signOutWithNaver" -> naverLogout()
                else -> result.notImplemented()
            }
        }
    }

    private fun naverLogout() {
        NidOAuth.logout(object : NidOAuthCallback {
            override fun onSuccess() {
                channelResult?.success(true)
                channelResult = null
            }

            override fun onFailure(code: String, message: String) {
                channelResult?.error("NAVER_LOGOUT_FAILURE", "errorCode: $code, errorMessage: $message", null)
                channelResult = null
            }
        })
    }

    private fun naverLogin() {

        val oauthLoginCallback = object : NidOAuthCallback {
            override fun onSuccess() {
                // 네이버 로그인 인증이 성공했을 때 수행할 코드 추가
                val accessToken = NidOAuth.getAccessToken()
                channelResult?.success(accessToken)
                channelResult = null
            }

            override fun onFailure(code: String, message: String) {
                // 네이버 로그인 인증이 실패했을 때 수행할 코드 추가
                channelResult?.error("NAVER_LOGIN_FAILURE", "errorCode: $code, errorMessage: $message", null)
                channelResult = null
            }
        }

        NidOAuth.requestLogin(this, oauthLoginCallback)
    }
}
