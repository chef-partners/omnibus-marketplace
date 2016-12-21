require("expose-loader?$!expose-loader?jQuery!foundation-sites/js/vendor/jquery.js");
require("file-loader?name=images/icons/all.svg!chef-web-core/dist/images/icons/all.svg");
require("script-loader!chef-web-core/dist/javascripts/chef.js");
require("../css/app.scss");

$(document).chef({
  assets: {
    images: "/biscotti/assets"
  }
});

$(document).ready(function () {
  $("#setup-form").on("valid.fndtn.abide", function (e) {
    $("button[name=starter-kit-form-button]").prop("disabled", true).html("Setting up Chef Automate..");
    $(this).off("submit").submit();

    $("#setup-form").addClass("hide");
    $("button[name=automate-login-button]").removeClass("hide");
  });
});
