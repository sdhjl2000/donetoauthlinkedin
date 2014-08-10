<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" ValidateRequest="false" Inherits="_Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>LinkedinAuth</title>
    <link rel="stylesheet" href="Content/bootstrap.min.css" />
    <script type="text/javascript" src="Scripts/jquery-1.9.1.min.js"></script>
    <script type="text/javascript" src="Scripts/bootstrap.min.js"></script>
</head>
<body >
    <form id="form1" runat="server" role="form" style="width: 80%;margin:0px auto;">
        <div class="form-group">
            <asp:HyperLink CssClass="btn btn-primary btn-lg btn-block" Target="_blank" ID="hypAuthToken" runat="server"></asp:HyperLink>

        </div>
        <div class="form-group">
             <asp:TextBox ID="txtoAuth_verifier" placeholder="填写授权码" CssClass="form-control" runat="server"></asp:TextBox>
        </div>
        <div class="form-group">
            <asp:Button ID="btnGetAccessToken" runat="server" Text="绑定"
                CssClass="btn btn-primary btn-lg btn-block" OnClick="btnGetAccessToken_Click" />
            <asp:TextBox ID="txtApiResponse" CssClass="form-control"   runat="server" TextMode="MultiLine" Rows="10" ></asp:TextBox>

        </div>
        <asp:HiddenField ID="txtTokenSecret" runat="server" />
        <asp:HiddenField ID="txtRequestToken" runat="server" />
        <asp:HiddenField ID="txtAccessTokenSecret" runat="server" />
        <asp:HiddenField ID="txtAccessToken" runat="server" />


    </form>



</body>
</html>
