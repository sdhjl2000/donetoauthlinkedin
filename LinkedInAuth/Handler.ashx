<%@ WebHandler Language="C#" Class="Handler" %>

using System;
using System.Web;

public class Handler : IHttpHandler {

    public void ProcessRequest(HttpContext context)
    { 
        context.Response.ContentType = "text/xml";
        var db = Model.LinkedinRepo.GetInstance();
        var record = db.SingleOrDefault<Model.UserBind>("SELECT * FROM UserBind WHERE ResourceId=@0", context.Request.QueryString["resourceid"]);
        if (context.Request.QueryString["action"] == "del")
        {
            if (record != null)
            {
                db.Delete(record);
                context.Response.Write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<linkedincomplete>\n<updateTag>Update5</updateTag></linkedincomplete>");
                context.Response.End(); 
            }
        }
        if (context.Request.QueryString["action"] == "bind")
        {
            if (record == null)
            {
                context.Response.Write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<linkedincomplete>\n<updateTag>Update5</updateTag></linkedincomplete>");
                context.Response.End();
            }
            else
            {
                oAuthLinkedIn _oauth = new oAuthLinkedIn();
                _oauth.Token = record.OAuthToken;
                _oauth.TokenSecret = record.OAuthSecret;
                _oauth.Verifier = record.VerifyNum;

                string response = _oauth.APIWebRequest("GET", "http://api.linkedin.com/v1/people/~:full", null);
                context.Response.Write(getEverything(response));
                context.Response.End();
            }
        }
    }
    public String getEverything(string resp)
  {
   System.Text.StringBuilder completeXML = new System.Text.StringBuilder("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<linkedincomplete>\n<updateTag>Update5</updateTag>");
   
    //completeXML.Append("<show><showProfile>false</showProfile><curJobExp>false</curJobExp><pastJobExp>false</pastJobExp><education>false</education><recommend>false</recommend><websites>false</websites><special>false</special><special>false</special><honors>false</honors><interests>false</interests></show>");
    if (!string.IsNullOrEmpty(resp))
    {
       
      String linkedInuserProfileData = resp;
       
      int index = linkedInuserProfileData.IndexOf("<person>");
      String substring = linkedInuserProfileData.Substring(index);
      System.Xml.XmlDocument xmlData=new System.Xml.XmlDocument();
      xmlData.LoadXml(substring);
      
      completeXML.Append("<person>");
      if (true)
      {
        completeXML.Append("<positions>");
        if ((notNull(xmlData.FirstChild, "positions")))
        {
          var jobNodes = xmlData.FirstChild.SelectNodes("positions");
          for (int i = 0; (i < jobNodes[0].ChildNodes.Count) && (jobNodes != null); i++)
          {
            var e = (System.Xml.XmlNode)jobNodes[0].ChildNodes[i];
            
            if ((e.SelectNodes("is-current") != null) && (((System.Xml.XmlNode)e.SelectNodes("is-current").Item(0)).InnerText=="true"))
            {
              completeXML.Append("<position>");
              String textContent = ((System.Xml.XmlNode)e.SelectNodes("title").Item(0)).InnerText;
              completeXML.Append("<title>" + textContent + "</title>");
              
              System.Xml.XmlNode company = (System.Xml.XmlNode)e.SelectNodes("company").Item(0);
              String name = ((System.Xml.XmlNode)company.SelectNodes("name").Item(0)).InnerText;
              
              completeXML.Append("<company><name>" + name + "</name></company>");
              completeXML.Append("<is-current>true</is-current>");
              completeXML.Append("</position>");
            }
            if ((e.SelectNodes("is-current") != null) && (((System.Xml.XmlNode)e.SelectNodes("is-current").Item(0)).InnerText == "false"))
            {
              completeXML.Append("<position>");
              String textContent = ((System.Xml.XmlNode)e.SelectNodes("title").Item(0)).InnerText;
              completeXML.Append("<title>" + textContent + "</title>");
              
              System.Xml.XmlNode company = (System.Xml.XmlNode)e.SelectNodes("company").Item(0);
              String name = ((System.Xml.XmlNode)company.SelectNodes("name").Item(0)).InnerText;
              
              completeXML.Append("<company><name>" + name + "</name></company>");
              completeXML.Append("<is-current>false</is-current>");
              completeXML.Append("</position>");
            }
          }
        }
        completeXML.Append("</positions>");
        if ((notNull(xmlData.FirstChild, "educations")))
        {
          completeXML.Append(xmlData.FirstChild.SelectNodes("educations").Item(0).OuterXml);
           
        }
        if ((notNull(xmlData.FirstChild, "num-recommenders"))) {
          completeXML.Append("<num-recommenders>" + ((System.Xml.XmlNode)xmlData.FirstChild.SelectNodes("num-recommenders").Item(0)).InnerText + "</num-recommenders>");
        }
        if ((notNull(xmlData.FirstChild, "member-url-resources"))) {
          completeXML.Append(xmlData.FirstChild.SelectNodes("member-url-resources").Item(0).OuterXml);
        }
        if ((notNull(xmlData.FirstChild, "specialties")))
        {
          String textContent = ((System.Xml.XmlNode)xmlData.FirstChild.SelectNodes("specialties").Item(0)).InnerText;
          completeXML.Append("<specialties>" + textContent + "</specialties>");
        }
        if ((notNull(xmlData.FirstChild, "honors")))
        {
          String textContent = ((System.Xml.XmlNode)xmlData.FirstChild.SelectNodes("honors").Item(0)).InnerText;
          completeXML.Append("<honors>" + textContent + "</honors>");
        }
        if ((notNull(xmlData.FirstChild, "interests")))
        {
          String textContent = ((System.Xml.XmlNode)xmlData.FirstChild.SelectNodes("interests").Item(0)).InnerText;
          completeXML.Append("<interests>" + textContent + "</interests>");
        }
        if (notNull(xmlData.FirstChild, "site-standard-profile-request"))
        {
            String textContent = ((System.Xml.XmlNode)((System.Xml.XmlNode)xmlData.FirstChild.SelectNodes("site-standard-profile-request").Item(0)).SelectNodes("url").Item(0)).InnerText;
            completeXML.Append("<site-standard-profile-request><url>" +insertEntities(textContent,true) + "</url></site-standard-profile-request>");
        }
      }
      completeXML.Append("</person>");
    }
    completeXML.Append("</linkedincomplete>");
     
    return completeXML.ToString();
  }
    public static String insertEntities(String txt, bool latin1)
    {
        System.Text.StringBuilder ret = new System.Text.StringBuilder();
        char[] c = txt.ToCharArray();
        for (int i = 0; i < c.Length; i++)
        {
            if (c[i] == '&')
            {
                ret.Append("&amp;");
            }
            else if (c[i] == '<')
            {
                ret.Append("&lt;");
            }
            else if (c[i] == '>')
            {
                ret.Append("&gt;");
            }
            else if (c[i] == '"')
            {
                ret.Append("&quot;");
            }
            else if ((c[i] >= ' ') && (c[i] < ''))
            {
                ret.Append(c[i]);
            }
            else if ((latin1) && (c[i] >= ' ') && (c[i] <= 'ÿ'))
            {
                ret.Append(LATIN1[(c[i] - ' ')]);
            }
            else
            {
                ret.Append("&#x");
                //ret.Append(Integer.toHexString(c[i]));
                ret.Append(((int)c[i]).ToString("X4"));
                ret.Append(";");
            }
        }
        return ret.ToString();
    }
    private static String[] LATIN1 = { "&nbsp;", "&iexcl;", "&cent;", 
    "&pound;", "&curren;", "&yen;", "&brvbar;", "&sect;", "&uml;", 
    "&copy;", "&ordf;", "&laquo;", "&#172;", "&shy;", "&reg;", 
    "&macr;", "&deg;", "&plusmn;", "&sup2;", "&sup3;", "&acute;", 
    "&micro;", "&para;", "&middot;", "&cedil;", "&sup1;", "&ordm;", 
    "&raquo;", "&frac14;", "&frac12;", "&frac34;", "&iquest;", 
    "&Agrave;", "&#193;", "&Acirc;", "&Atilde;", "&Auml;", "&Aring;", 
    "&AElig;", "&Ccedil;", "&Egrave;", "&Eacute;", "&Ecirc;", "&Euml;", 
    "&Igrave;", "&Iacute;", "&Icirc;", "&Iuml;", "&ETH;", "&Ntilde;", 
    "&Ograve;", "&Oacute;", "&Ocirc;", "&Otilde;", "&Ouml;", "&times;", 
    "&Oslash;", "&Ugrave;", "&Uacute;", "&Ucirc;", "&Uuml;", 
    "&Yacute;", "&THORN;", "&szlig;", "&agrave;", "&aacute;", 
    "&acirc;", "&atilde;", "&auml;", "&aring;", "&aelig;", "&ccedil;", 
    "&egrave;", "&eacute;", "&ecirc;", "&euml;", "&igrave;", 
    "&iacute;", "&icirc;", "&iuml;", "&eth;", "&ntilde;", "&ograve;", 
    "&oacute;", "&ocirc;", "&otilde;", "&ouml;", "&divide;", 
    "&oslash;", "&ugrave;", "&uacute;", "&ucirc;", "&uuml;", 
    "&yacute;", "&thorn;", "&yuml;" };
    private bool notNull(System.Xml.XmlNode xmlData, String tagName)
    {
        return (xmlData.SelectNodes(tagName) != null) && ((System.Xml.XmlNode)xmlData.SelectNodes(tagName).Item(0) != null);
    }
    public bool IsReusable {
        get {
            return false;
        }
    }

}