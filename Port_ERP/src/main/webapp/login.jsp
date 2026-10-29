<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>PORT ERP - Login</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"/>
<style>
*{margin:0;padding:0;box-sizing:border-box;font-family:'Inter',sans-serif;}
body{min-height:100vh;display:flex;justify-content:center;align-items:center;background:#f4f7fb;padding:20px;}
.login-container{width:100%;max-width:1000px;background:white;border-radius:30px;overflow:hidden;display:flex;box-shadow:0 10px 40px rgba(15,23,42,0.08);}
.left-section{width:50%;background:#1f3557;padding:70px 60px;display:flex;flex-direction:column;justify-content:center;color:white;}
.logo{width:80px;height:80px;border-radius:22px;background:rgba(255,255,255,0.08);display:flex;justify-content:center;align-items:center;font-size:34px;margin-bottom:35px;border:1px solid rgba(255,255,255,0.10);}
.left-section h1{font-size:42px;font-weight:700;line-height:1.2;margin-bottom:20px;}
.left-section p{font-size:15px;line-height:1.9;color:#d6dfeb;}
.right-section{width:50%;padding:70px 60px;display:flex;flex-direction:column;justify-content:center;}
.login-header{margin-bottom:35px;}
.login-header h2{font-size:34px;color:#111827;margin-bottom:10px;font-weight:700;}
.login-header p{color:#6b7280;font-size:15px;}
.error{background:#fef2f2;color:#dc2626;border:1px solid #fecaca;padding:14px 16px;border-radius:14px;margin-bottom:24px;font-size:14px;}
.input-box{margin-bottom:24px;}
.input-box label{display:block;margin-bottom:10px;font-size:14px;font-weight:600;color:#374151;}
.input-wrapper{position:relative;}
.input-wrapper i{position:absolute;top:18px;left:18px;color:#94a3b8;font-size:15px;}
.input-wrapper input{width:100%;padding:16px 18px 16px 50px;border:1px solid #dbe2ea;border-radius:16px;outline:none;background:#f9fafb;font-size:15px;transition:0.3s;}
.input-wrapper input:focus{border-color:#1f3557;background:white;box-shadow:0 0 0 4px rgba(31,53,87,0.08);}
.login-btn{width:100%;padding:16px;border:none;border-radius:16px;background:#1f3557;color:white;font-size:16px;font-weight:600;cursor:pointer;transition:0.3s;}
.login-btn:hover{background:#162844;}
.footer{margin-top:28px;text-align:center;font-size:13px;color:#94a3b8;line-height:1.8;}
@media(max-width:900px){.login-container{flex-direction:column;}.left-section,.right-section{width:100%;}.left-section{padding:50px 35px;}.right-section{padding:50px 35px;}.left-section h1{font-size:34px;}}
@media(max-width:500px){.left-section,.right-section{padding:40px 25px;}.login-header h2{font-size:28px;}}
</style>
</head>
<body>
<div class="login-container">
    <div class="left-section">
        <div class="logo"><i class="fa-solid fa-anchor"></i></div>
        <h1>Port ERP<br>Management System</h1>
        <p>Centralized enterprise platform for managing port operations, ships, docks, cargo handling, logistics and system users securely.</p>
    </div>
    <div class="right-section">
        <div class="login-header">
            <h2>Welcome User</h2>
            <p>Login to access your dashboard</p>
        </div>
        <% String error = (String) request.getAttribute("error"); if(error != null){ %>
        <div class="error">
            <i class="fa-solid fa-circle-exclamation"></i>&nbsp; <%= error %>
        </div>
        <% } %>
        <form action="LoginController" method="post">
            <div class="input-box">
                <label>Email Address</label>
                <div class="input-wrapper">
                    <i class="fa-solid fa-envelope"></i>
                    <input type="email" name="email" placeholder="Enter your email" required>
                </div>
            </div>
            <div class="input-box">
                <label>Password</label>
                <div class="input-wrapper">
                    <i class="fa-solid fa-lock"></i>
                    <input type="password" name="password" placeholder="Enter your password" required>
                </div>
            </div>
            <button type="submit" class="login-btn">
                <i class="fa-solid fa-right-to-bracket"></i>&nbsp; Login
            </button>
        </form>
        <div class="footer">© 2026 PORT ERP <br>Enterprise Resource Planning System</div>
    </div>
</div>
</body>
</html>