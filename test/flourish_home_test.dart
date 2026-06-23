import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/config/language.dart';
import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flourish_flutter_sdk/web_view/flourish_token_error_page.dart';
import 'package:flourish_flutter_sdk/web_view/webview_container.dart';

import 'helpers/test_doubles.dart';

void main() {
  group('Flourish.home', () {
    test('returns a WebviewContainer when the token is valid', () async {
      final flourish = await flourishWithStaticToken(token: 'valid');
      expect(flourish.home(), isA<WebviewContainer>());
    });

    test('threads redirectTo and resourceId into the container', () async {
      final flourish = await flourishWithStaticToken(token: 'valid');
      final widget =
          flourish.home(redirectTo: 'PARTNER_STORE_DETAIL', resourceId: '123')
              as WebviewContainer;
      expect(widget.redirectTo, 'PARTNER_STORE_DETAIL');
      expect(widget.resourceId, '123');
    });

    test('returns the default token-error page when the token is invalid',
        () async {
      final flourish = await flourishWithStaticToken(token: 'valid');
      flourish.token = '';
      expect(flourish.home(), isA<FlourishTokenErrorPage>());
    });

    test('returns the onTokenErrorWidget override when provided and invalid',
        () async {
      const override = SizedBox(key: Key('custom-error'));
      final flourish = await Flourish.create(
        uuid: 'u',
        secret: 's',
        env: Environment.development,
        language: Language.english,
        customerCode: 'c',
        debugStaticToken: 'valid',
        onTokenErrorWidget: override,
      );
      flourish.token = '';
      expect(flourish.home(), same(override));
    });
  });
}
