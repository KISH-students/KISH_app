class KISHApi {
  static const String HOST = "https://kish-dev.kro.kr/";
  static const String API_ROOT = HOST + "api/";
  static const String MAGAZINE_ROOT = API_ROOT + "kish-magazine/";
  static const String POST_ROOT = API_ROOT + "post/";

  static const String GET_EXAM_DATES = API_ROOT + "getExamDates";
  static const String GET_LUNCH = API_ROOT + "getLunch";

  static const String SEARCH_POST = POST_ROOT + "searchPost";
  static const String GET_POSTS_BY_MENU = POST_ROOT + "getPostsByMenu";
  static const String GET_LAST_UPDATED_MENU_LIST = POST_ROOT + "getLastUpdatedMenuList";
  static const String GET_POST_CONTENT_HTML = POST_ROOT + "getPostContentHtml";
  static const String GET_POST_ATTACHMENTS = POST_ROOT + "getPostAttachments";
  static const String GET_POST_LIST_HOME_SUMMARY = POST_ROOT + "getPostListHomeSummary";

  static const String GET_MAGAZINE_ARTICLE = MAGAZINE_ROOT + "getArticleList";
}
