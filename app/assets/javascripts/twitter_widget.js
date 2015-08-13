$(window).load(function()
{
// Define the style variables
var $background_color = "#ffffff";
var $font = "'Source Sans Pro', Arial, sans-serif;";
var $font_weight = "normal";
var $border_color = "#fff";
var $border_radius = "0px";
var $text_color = "#1ABC9C";
var $link_color = "#1ABC9C";
var $name_color = "#eee";
var $subtext_color = "#eee"; // Colour of any small text
var $sublink_color = "#eee"; // Colour of smaller links, eg: @user, date, expand/collapse links
var $avatar_border = "0px solid #fff";
var $avatar_border_radius = "0";
var $icon_color = "#1ABC9C"; // Color of the reply/retweet/favourite icons
var $icon_hover_color = "#1ABC9C"; // Hover color the reply/retweet/favourite icons
var $header_background = "#1ABC9C";
var $header_text_color = "#ffffff";
var $follow_button_link_color = "#1ABC9C";
var $footer_background = "#36b787";
var $footer_tweetbox_background = "#2d936d";
var $footer_tweetbox_textcolor = "#ffffff";
var $footer_tweetbox_border ="0px";
var $load_more_background ="#1ABC9C";
var $load_more_text_color = "#ffffff";

// Apply the styles
$("iframe").contents().find('head').append(
  '<style>.html, body, h1, h2, h3, blockquote, p, ol, ul, li, img, iframe, button, .tweet-box-button{font-family:'+$font+' !important;font-weight:'+$font_weight+' !important;} h1, h2, h3, blockquote, p, ol, ul, li {padding-left: 12px !important; padding-right: 12px !important;} .timeline{border-radius: ' + $border_radius + '!important;} .thm-dark .retweet-credit,.h-feed, .stats strong{color:' + $text_color + ' !important;}a:not(.follow-button):not(.tweet-box-button):not(.expand):not(.u-url), .load-more{color:' + $link_color + ' ;} .follow-button{color:' + $follow_button_link_color + ' !important;} .timeline-header{background:' + $header_background + '; border-radius:' + $border_radius + ' ' + $border_radius + ' 0px 0px;} .timeline-header h1 a{color:' + $header_text_color + ' !important;} .tweet-box-button{background-color:' + $footer_tweetbox_background + ' !important; color:' + $footer_tweetbox_textcolor + ' !important; border:' + $footer_tweetbox_border + ' !important;} .timeline .stream, .tweet-actions{box-shadow:0 0 10px 5px' + $background_color + ' !important;} .ic-mask{background-color:' + $icon_color + ' !important;} a:hover .ic-mask, a:focus .ic-mask{background-color:' + $icon_hover_color + ' !important;} .header .avatar{border-radius: '+ $avatar_border_radius + ' !important; border:' + $avatar_border + ' !important;} .p-name{color:'+$name_color+' !important;} span.p-nickname, .u-url, .expand{color:'+$sublink_color+' !important;} .load-more, .no-more-pane {background-color:' + $load_more_background + ' !important; color:' + $load_more_text_color + '!important;} .retweet-credit{color:' + $subtext_color + ' !important;}</style>');
});