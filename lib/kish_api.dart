class KISHApi {
  static const String HOST = "https://kish-dev.kro.kr/";
  static const String API_ROOT = HOST + "api/";
  static const String MAGAZINE_ROOT = API_ROOT + "kish-magazine/";
  static const String POST_ROOT = API_ROOT + "post/";
  static const String LIBRARY_ROOT = API_ROOT + "library/";
  static const String BAMBOO_ROOT = API_ROOT + "bamboo/";

  static const String GET_EXAM_DATES = API_ROOT + "getExamDates";
  static const String GET_LUNCH = API_ROOT + "getLunch";

  static const String SEARCH_POST = POST_ROOT + "searchPost";
  static const String GET_POSTS_BY_MENU = POST_ROOT + "getPostsByMenu";
  static const String GET_LAST_UPDATED_MENU_LIST = POST_ROOT + "getLastUpdatedMenuList";
  static const String GET_POST_CONTENT_HTML = POST_ROOT + "getPostContentHtml";
  static const String GET_POST_ATTACHMENTS = POST_ROOT + "getPostAttachments";
  static const String GET_POST_LIST_HOME_SUMMARY = POST_ROOT + "getPostListHomeSummary";

  static const String LIBRARY_LOGIN = LIBRARY_ROOT + "login";
  static const String LIBRARY_LOGOUT = LIBRARY_ROOT + "logout";
  static const String LIBRARY_MY_INFO = LIBRARY_ROOT + "getInfo";
  static const String LIBRARY_REGISTER = LIBRARY_ROOT + "register";
  static const String IS_LIBRARY_Member = LIBRARY_ROOT + "isMember";

  static const String GET_MAGAZINE_ARTICLE = MAGAZINE_ROOT + "getArticleList";
  static const String GET_MAGAZINE_HOME = MAGAZINE_ROOT + "home";
  static const String GET_MAGAZINE_PARENT_LIST = MAGAZINE_ROOT + "getParentList";
  static const String GET_MAGAZINE_CATEGORY_LIST = MAGAZINE_ROOT + "getCategoryList";

  static const String BAMBOO_GET_POSTS = BAMBOO_ROOT + "posts";
  static const String BAMBOO_GET_MY_POSTS = BAMBOO_ROOT + "myPosts";
  static const String BAMBOO_GET_MY_COMMENTS = BAMBOO_ROOT + "myComments";
  static const String BAMBOO_WRITE_POST = BAMBOO_ROOT + "writePost";
  static const String BAMBOO_GET_POST = BAMBOO_ROOT + "post";
  static const String BAMBOO_WRITE_COMMENT = BAMBOO_ROOT + "writeComment";
  static const String BAMBOO_REPLY = BAMBOO_ROOT + "reply";
  static const String BAMBOO_LIKE_POST = BAMBOO_ROOT + "likePost";
  static const String BAMBOO_LIKE_COMMENT = BAMBOO_ROOT + "likeComment";
  static const String BAMBOO_UNLIKE_POST = BAMBOO_ROOT + "unlikePost";
  static const String BAMBOO_UNLIKE_COMMENT = BAMBOO_ROOT + "unlikeComment";
  static const String BAMBOO_GET_REPLIES = BAMBOO_ROOT + "getReplies";
  static const String BAMBOO_DELETE_POST = BAMBOO_ROOT + "deletePost";
  static const String BAMBOO_DELETE_COMMENT = BAMBOO_ROOT + "deleteComment";
  static const String BAMBOO_TOGGLE_NOTIFICATION = BAMBOO_ROOT + "notification";
  static const String BAMBOO_MY_NOTIFICATION = BAMBOO_ROOT + "myNotification";
}
