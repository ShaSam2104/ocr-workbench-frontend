import 'dart:convert';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

/// Start OCR Workbench API Group Code

class OCRWorkbenchAPIGroup {
  static String getBaseUrl() {
    // In production (web builds), use relative path for nginx proxy
    // In development, use localhost backend directly
    if (kIsWeb) {
      // Production: Use /api prefix (proxied by nginx to backend:8000/)
      return '/api';
    }
    // Development: Use hardcoded backend URL
    return 'http://localhost:8001';
  }
  static Map<String, String> headers = {};
  static LoginCall loginCall = LoginCall();
  static LogoutCall logoutCall = LogoutCall();
  static RegisterCall registerCall = RegisterCall();
  static ListBooksCall listBooksCall = ListBooksCall();
  static CreateBookCall createBookCall = CreateBookCall();
  static GetBookCall getBookCall = GetBookCall();
  static UpdateBookCall updateBookCall = UpdateBookCall();
  static DeleteBookCall deleteBookCall = DeleteBookCall();
  static ListChaptersCall listChaptersCall = ListChaptersCall();
  static CreateChapterCall createChapterCall = CreateChapterCall();
  static GetChapterImagesCall getChapterImagesCall = GetChapterImagesCall();
  static GetChapterAudiosCall getChapterAudiosCall = GetChapterAudiosCall();
  static UpdateImageTextCall updateImageTextCall = UpdateImageTextCall();
  static UpdateAudioTranscriptCall updateAudioTranscriptCall =
      UpdateAudioTranscriptCall();
  static UpdateChapterCall updateChapterCall = UpdateChapterCall();
  static UpdateImageOrderCall updateImageOrderCall = UpdateImageOrderCall();
  static UpdateAudiosOrderCall updateAudiosOrderCall = UpdateAudiosOrderCall();
  static DeleteChapterCall deleteChapterCall = DeleteChapterCall();
  static DeleteAllImagesInChapterCall deleteAllImagesInChapterCall =
      DeleteAllImagesInChapterCall();
  static DeleteAllAudiosInChapterCall deleteAllAudiosInChapterCall =
      DeleteAllAudiosInChapterCall();
  static DeleteImageCall deleteImageCall = DeleteImageCall();
  static DeleteAudioCall deleteAudioCall = DeleteAudioCall();
  static UploadImagesCall uploadImagesCall = UploadImagesCall();
  static UploadAudiosCall uploadAudiosCall = UploadAudiosCall();
  static ProcessImagesOcrCall processImagesOcrCall = ProcessImagesOcrCall();
  static GetOcrStatusCall getOcrStatusCall = GetOcrStatusCall();
  static TranscribeAudiosCall transcribeAudiosCall = TranscribeAudiosCall();
  static GetTranscriptionStatusCall getTranscriptionStatusCall =
      GetTranscriptionStatusCall();
  static GetImageTextCall getImageTextCall = GetImageTextCall();
  static GetAudioTranscriptCall getAudioTranscriptCall =
      GetAudioTranscriptCall();
  static SearchImagesByNumberCall searchImagesByNumberCall =
      SearchImagesByNumberCall();
  static SearchAudiosByNumberCall searchAudiosByNumberCall =
      SearchAudiosByNumberCall();
  static SearchImagesByTextCall searchImagesByTextCall =
      SearchImagesByTextCall();
  static SearchAudiosByTextCall searchAudiosByTextCall =
      SearchAudiosByTextCall();
  static SearchChapterCall searchChapterCall = SearchChapterCall();
  static SearchBookCall searchBookCall = SearchBookCall();
  static SearchGlobalCall searchGlobalCall = SearchGlobalCall();
  static ExportFolderCall exportFolderCall = ExportFolderCall();
  static ExportSelectionCall exportSelectionCall = ExportSelectionCall();
  static HealthCheckCall healthCheckCall = HealthCheckCall();
}

class LoginCall {
  Future<ApiCallResponse> call({
    String? username = '',
    String? password = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "username": "${escapeStringForJson(username)}",
  "password": "${escapeStringForJson(password)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Login',
      apiUrl: '${baseUrl}/auth/login',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class LogoutCall {
  Future<ApiCallResponse> call() async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Logout',
      apiUrl: '${baseUrl}/auth/logout',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class RegisterCall {
  Future<ApiCallResponse> call() async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "username": "",
  "password": ""
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Register',
      apiUrl: '${baseUrl}/auth/register',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ListBooksCall {
  Future<ApiCallResponse> call({
    int? page,
    int? pageSize,
    String? hTTPBearer = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Books',
      apiUrl: '${baseUrl}/books',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {
        'page': page,
        'page_size': pageSize,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CreateBookCall {
  Future<ApiCallResponse> call({
    String? hTTPBearer = '',
    String? name = '',
    String? description = '',
    List<String>? languagesList,
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();
    final languages = _serializeList(languagesList);

    final ffApiRequestBody = '''
{
  "name": "${escapeStringForJson(name)}",
  "description": "${escapeStringForJson(description)}",
  "languages": ${languages}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Book',
      apiUrl: '${baseUrl}/books',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetBookCall {
  Future<ApiCallResponse> call({
    int? bookId,
    String? hTTPBearer = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Book',
      apiUrl: '${baseUrl}/books/${bookId}',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateBookCall {
  Future<ApiCallResponse> call({
    int? bookId,
    String? hTTPBearer = '',
    String? name = '',
    String? description = '',
    List<String>? languagesList,
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();
    final languages = _serializeList(languagesList);

    final ffApiRequestBody = '''
{
  "name": "${escapeStringForJson(name)}",
  "description": "${escapeStringForJson(description)}",
  "languages": ${languages}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update Book',
      apiUrl: '${baseUrl}/books/${bookId}',
      callType: ApiCallType.PUT,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class DeleteBookCall {
  Future<ApiCallResponse> call({
    int? bookId,
    String? hTTPBearer = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Delete Book',
      apiUrl: '${baseUrl}/books/${bookId}',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ListChaptersCall {
  Future<ApiCallResponse> call({
    int? bookId,
    int? page,
    int? pageSize,
    String? hTTPBearer = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List Chapters',
      apiUrl: '${baseUrl}/books/${bookId}/chapters',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {
        'page': page,
        'page_size': pageSize,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CreateChapterCall {
  Future<ApiCallResponse> call({
    int? bookId,
    String? hTTPBearer = '',
    String? name = '',
    String? description = '',
    int? sequenceOrder,
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "name": "${escapeStringForJson(name)}",
  "description": "${escapeStringForJson(description)}",
  "sequence_order": ${sequenceOrder}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Chapter',
      apiUrl: '${baseUrl}/books/${bookId}/chapters',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetChapterImagesCall {
  Future<ApiCallResponse> call({
    int? bookId,
    int? chapterId,
    String? hTTPBearer = '',
    int? page,
    int? pageSize,
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Chapter Images',
      apiUrl: '${baseUrl}/books/${bookId}/chapters/${chapterId}/images',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {
        'page': page,
        'page_size': pageSize,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetChapterAudiosCall {
  Future<ApiCallResponse> call({
    int? bookId,
    int? chapterId,
    String? hTTPBearer = '',
    int? page,
    int? pageSize,
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Chapter Audios',
      apiUrl: '${baseUrl}/books/${bookId}/chapters/${chapterId}/audios',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {
        'page': page,
        'page_size': pageSize,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateImageTextCall {
  Future<ApiCallResponse> call({
    int? imageId,
    String? hTTPBearer = '',
    String? textWithFormatting = '',
    String? plainText = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "text_with_formatting": "${escapeStringForJson(textWithFormatting)}",
  "plain_text": "${escapeStringForJson(plainText)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update Image text',
      apiUrl: '${baseUrl}/images/${imageId}/text',
      callType: ApiCallType.PUT,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateAudioTranscriptCall {
  Future<ApiCallResponse> call({
    int? audioId,
    String? hTTPBearer = '',
    String? textWithFormatting = '',
    String? plainText = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "text_with_formatting": "${escapeStringForJson(textWithFormatting)}",
  "plain_text": "${escapeStringForJson(plainText)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update audio transcript',
      apiUrl: '${baseUrl}/audio/${audioId}/transcript',
      callType: ApiCallType.PUT,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateChapterCall {
  Future<ApiCallResponse> call({
    int? bookId,
    int? chapterId,
    String? hTTPBearer = '',
    String? name = '',
    String? description = '',
    int? sequenceOrder,
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "name": "${escapeStringForJson(name)}",
  "description": "${escapeStringForJson(description)}",
  "sequence_order": ${sequenceOrder}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update Chapter',
      apiUrl: '${baseUrl}/books/${bookId}/chapters/${chapterId}',
      callType: ApiCallType.PUT,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateImageOrderCall {
  Future<ApiCallResponse> call({
    int? chapterId,
    String? hTTPBearer = '',
    List<Map<String, int>>? reordersList,
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();
    final reorders = reordersList ?? [];
    
    // Build the images array
    final imagesArray = reorders.map((item) => '''{
      "current_sequence_number": ${item['currentSequenceNumber']},
      "new_sequence_number": ${item['newSequenceNumber']}
    }''').join(',');

    final ffApiRequestBody = '''{
  "images": [
    ${imagesArray}
  ]
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update Image Order',
      apiUrl: '${baseUrl}/chapters/${chapterId}/images/reorder',
      callType: ApiCallType.PUT,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateAudiosOrderCall {
  Future<ApiCallResponse> call({
    int? chapterId,
    String? hTTPBearer = '',
    List<Map<String, int>>? reordersList,
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();
    final reorders = reordersList ?? [];
    
    // Build the audios array
    final audiosArray = reorders.map((item) => '''{
      "current_sequence_number": ${item['currentSequenceNumber']},
      "new_sequence_number": ${item['newSequenceNumber']}
    }''').join(',');

    final ffApiRequestBody = '''{
  "audios": [
    ${audiosArray}
  ]
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update Audios Order',
      apiUrl: '${baseUrl}/chapters/${chapterId}/audios/reorder',
      callType: ApiCallType.PUT,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class DeleteChapterCall {
  Future<ApiCallResponse> call({
    int? bookId,
    int? chapterId,
    String? hTTPBearer = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Delete Chapter',
      apiUrl: '${baseUrl}/books/${bookId}/chapters/${chapterId}',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class DeleteAllImagesInChapterCall {
  Future<ApiCallResponse> call({
    int? chapterId,
    String? hTTPBearer = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Delete All Images In Chapter',
      apiUrl: '${baseUrl}/chapters/${chapterId}/images',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class DeleteAllAudiosInChapterCall {
  Future<ApiCallResponse> call({
    int? chapterId,
    String? hTTPBearer = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Delete All Audios In Chapter',
      apiUrl: '${baseUrl}/chapters/${chapterId}/audios',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class DeleteImageCall {
  Future<ApiCallResponse> call({
    int? imageId,
    String? hTTPBearer = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Delete Image',
      apiUrl: '${baseUrl}/images/${imageId}',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class DeleteAudioCall {
  Future<ApiCallResponse> call({
    int? audioId,
    String? hTTPBearer = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Delete Audio',
      apiUrl: '${baseUrl}/audios/${audioId}',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UploadImagesCall {
  Future<ApiCallResponse> call({
    int? chapterId,
    String? hTTPBearer = '',
    List<FFUploadedFile>? filesList,
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();
    final files = filesList ?? [];

    return ApiManager.instance.makeApiCall(
      callName: 'Upload Images',
      apiUrl: '${baseUrl}/chapters/${chapterId}/images/upload',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {
        'files': files,
      },
      bodyType: BodyType.MULTIPART,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UploadAudiosCall {
  Future<ApiCallResponse> call({
    int? chapterId,
    String? hTTPBearer = '',
    List<FFUploadedFile>? filesList,
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();
    final files = filesList ?? [];

    return ApiManager.instance.makeApiCall(
      callName: 'Upload Audios',
      apiUrl: '${baseUrl}/chapters/${chapterId}/audios/upload',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {
        'files': files,
      },
      bodyType: BodyType.MULTIPART,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ProcessImagesOcrCall {
  Future<ApiCallResponse> call({
    String? hTTPBearer = '',
    List<int>? imageIdsList,
    String? model = 'lower',
    String? customPrompt = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();
    final imageIds = _serializeList(imageIdsList);

    final ffApiRequestBody = '''
{
  "image_ids": ${imageIds},
  "model": "${escapeStringForJson(model)}",
  "custom_prompt": "${escapeStringForJson(customPrompt)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Process Images Ocr',
      apiUrl: '${baseUrl}/ocr/process',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetOcrStatusCall {
  Future<ApiCallResponse> call({
    String? taskId = '',
    String? hTTPBearer = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Ocr Status',
      apiUrl: '${baseUrl}/ocr/status/${taskId}',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class TranscribeAudiosCall {
  Future<ApiCallResponse> call({
    String? hTTPBearer = '',
    List<int>? audioIdsList,
    String? languageHint = '',
    String? model = 'lower',
    String? customPrompt = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();
    final audioIds = _serializeList(audioIdsList);

    final ffApiRequestBody = '''
{
  "audio_ids": ${audioIds},
  "language_hint": "${escapeStringForJson(languageHint)}",
  "model": "${escapeStringForJson(model)}",
  "custom_prompt": "${escapeStringForJson(customPrompt)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Transcribe Audios',
      apiUrl: '${baseUrl}/audio/transcribe',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetTranscriptionStatusCall {
  Future<ApiCallResponse> call({
    String? taskId = '',
    String? hTTPBearer = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Transcription Status',
      apiUrl: '${baseUrl}/audio/transcription/status/${taskId}',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetImageTextCall {
  Future<ApiCallResponse> call({
    int? imageId,
    String? hTTPBearer = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Image Text',
      apiUrl: '${baseUrl}/images/${imageId}/text',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetAudioTranscriptCall {
  Future<ApiCallResponse> call({
    int? audioId,
    String? hTTPBearer = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Audio Transcript',
      apiUrl: '${baseUrl}/audio/${audioId}/transcript',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SearchImagesByNumberCall {
  Future<ApiCallResponse> call({
    int? chapterId,
    String? query = '',
    String? hTTPBearer = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Search Images By Number',
      apiUrl: '${baseUrl}/search/images',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {
        'chapter_id': chapterId,
        'query': query,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SearchAudiosByNumberCall {
  Future<ApiCallResponse> call({
    int? chapterId,
    String? query = '',
    String? hTTPBearer = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Search Audios By Number',
      apiUrl: '${baseUrl}/search/audios',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {
        'chapter_id': chapterId,
        'query': query,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SearchImagesByTextCall {
  Future<ApiCallResponse> call({
    String? textQuery = '',
    String? hTTPBearer = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Search Images By Text',
      apiUrl: '${baseUrl}/search/images/text',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {
        'text_query': textQuery,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SearchAudiosByTextCall {
  Future<ApiCallResponse> call({
    String? textQuery = '',
    String? hTTPBearer = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Search Audios By Text',
      apiUrl: '${baseUrl}/search/audios/text',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {
        'text_query': textQuery,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SearchChapterCall {
  Future<ApiCallResponse> call({
    int? chapterId,
    String? textQuery = '',
    String? hTTPBearer = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Search Chapter',
      apiUrl: '${baseUrl}/search/chapter',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {
        'chapter_id': chapterId,
        'text_query': textQuery,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SearchBookCall {
  Future<ApiCallResponse> call({
    int? bookId,
    String? textQuery = '',
    String? hTTPBearer = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Search Book',
      apiUrl: '${baseUrl}/search/book',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {
        'book_id': bookId,
        'text_query': textQuery,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SearchGlobalCall {
  Future<ApiCallResponse> call({
    String? textQuery = '',
    String? hTTPBearer = '',
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Search Global',
      apiUrl: '${baseUrl}/search/global',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {
        'text_query': textQuery,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ExportFolderCall {
  Future<ApiCallResponse> call({
    String? hTTPBearer = '',
    int? bookId,
    int? chapterId,
    String? format = '',
    bool? includeImages,
    bool? includeAudioTranscripts,
    bool? includePageBreaks,
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "book_id": ${bookId},
  "chapter_id": ${chapterId},
  "format": "${escapeStringForJson(format)}",
  "include_images": ${includeImages},
  "include_audio_transcripts": ${includeAudioTranscripts},
  "include_page_breaks": ${includePageBreaks}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Export Folder',
      apiUrl: '${baseUrl}/export/folder',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ExportSelectionCall {
  Future<ApiCallResponse> call({
    String? hTTPBearer = '',
    List<int>? imageIdsList,
    List<int>? audioIdsList,
    String? format = '',
    bool? includeImages,
  }) async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();
    final imageIds = _serializeList(imageIdsList);
    final audioIds = _serializeList(audioIdsList);

    final ffApiRequestBody = '''
{
  "image_ids": ${imageIds},
  "audio_ids": ${audioIds},
  "format": "${escapeStringForJson(format)}",
  "include_images": ${includeImages}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Export Selection',
      apiUrl: '${baseUrl}/export/selection',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${hTTPBearer}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class HealthCheckCall {
  Future<ApiCallResponse> call() async {
    final baseUrl = OCRWorkbenchAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Health Check',
      apiUrl: '${baseUrl}/health',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// End OCR Workbench API Group Code

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
