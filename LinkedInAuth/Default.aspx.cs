using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using Model;

public partial class _Default : System.Web.UI.Page 
{
    private oAuthLinkedIn _oauth = new oAuthLinkedIn();
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            if (string.IsNullOrEmpty(Request.QueryString["resourceid"]))
            {
                btnGetAccessToken.Enabled = false;
                hypAuthToken.Enabled = false;
                return;
                
            }
                string authLink = _oauth.AuthorizationLinkGet();
                txtRequestToken.Value = _oauth.Token;
                txtTokenSecret.Value = _oauth.TokenSecret;
                hypAuthToken.NavigateUrl = authLink;
                hypAuthToken.Text = "获取授权码";
                
        }
         
    }

    

    protected void btnGetAccessToken_Click(object sender, EventArgs e)
    {
        _oauth.Token = txtRequestToken.Value;
        _oauth.TokenSecret = txtTokenSecret.Value;
        _oauth.Verifier = txtoAuth_verifier.Text;

        _oauth.AccessTokenGet(txtRequestToken.Value);
        txtAccessToken.Value = _oauth.Token;
        txtAccessTokenSecret.Value = _oauth.TokenSecret;

        string response = _oauth.APIWebRequest("GET", "http://api.linkedin.com/v1/people/~:full", null);
        txtApiResponse.Text = response;
        ClientScript.RegisterStartupScript(this.GetType(),"sucess","alert('绑定成功，请返回个人档案页面刷新页面');",true);
        var db = Model.LinkedinRepo.GetInstance();
        var record= db.SingleOrDefault<Model.UserBind>("SELECT * FROM UserBind WHERE ResourceId=@0", Request.QueryString["resourceid"]);
        if (record == null)
        {
            record=new UserBind(){OAuthToken = txtAccessToken.Value,ResourceId = Request.QueryString["resourceid"],OAuthSecret = txtAccessTokenSecret.Value,VerifyNum = txtoAuth_verifier.Text.Trim()};
            db.Save(record);
        }
        else
        {
            record.OAuthSecret = txtAccessTokenSecret.Value;
            record.OAuthToken = txtAccessToken.Value;
            record.VerifyNum = txtoAuth_verifier.Text.Trim();
            db.Update(record);
        }
    }

    
}
