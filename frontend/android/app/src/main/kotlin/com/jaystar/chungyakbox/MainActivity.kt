package com.jaystar.chungyakbox

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import com.navercorp.nid.NaverIdLoginSDK
import com.navercorp.nid.oauth.OAuthLoginCallback


class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.chungyakbox/auth"
    private var channelResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "signInWithNaver") {
                channelResult = result
                naverLogin()
            } else {
                result.notImplemented()
            }
        }
    }

    private fun naverLogin() {
        // Naver SDK 초기화
        // strings.xml에서 클라이언트 정보 가져오기
        val naverClientId = getString(R.string.naver_client_id)
        val naverClientSecret = getString(R.string.naver_client_secret)
        val naverClientName = getString(R.string.naver_client_name)

        NaverIdLoginSDK.initialize(this, naverClientId, naverClientSecret, naverClientName)

        val oauthLoginCallBack = object : OAuthLoginCallback {
            override fun onSuccess() {
                // 네이버 로그인 인증이 성공했을 때 수행할 코드 추가
                val accessToken = NaverIdLoginSDK.getAccessToken()
                //val refreshToken = NaverIdLoginSDK.getRefreshToken()
                //val expiresAt = NaverIdLoginSDK.getExpiresAt()
                //val tokenType = NaverIdLoginSDK.getTokenType()
                //val state = NaverIdLoginSDK.getState()

                channelResult?.success(accessToken)
                channelResult = null
            }
            override fun onFailure(httpStatus: Int, message: String) {
                // 네이버 로그인 인증이 실패했을 때 수행할 코드 추가
                val errorCode = NaverIdLoginSDK.getLastErrorCode().code
                val errorDescription = NaverIdLoginSDK.getLastErrorDescription()
                channelResult?.error("NAVER_LOGIN_FAILURE", "errorCode: $errorCode, errorDescription: $errorDescription", null)
                channelResult = null
            }
            override fun onError(errorCode: Int, message: String) {
                // 네이버 로그인 인증 도중에 오류가 발생했을 때 수행할 코드 추가
                onFailure(errorCode, message)
            }
        }

        NaverIdLoginSDK.authenticate(this, oauthLoginCallBack)
    }
}
