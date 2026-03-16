<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>CrechePet — Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet"/>
    <style>
        :root {
            --cor-primaria: #3b82f6;
            --cor-primaria-hover: #2563eb;
            --cor-fundo: #f0f4ff;
        }

        body {
            background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 60%, #60a5fa 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', sans-serif;
        }

        .card-login {
            background: #ffffff;
            border-radius: 20px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.25);
            width: 100%;
            max-width: 420px;
            padding: 2.5rem;
        }

        .logo-area {
            text-align: center;
            margin-bottom: 2rem;
        }

        .logo-icon {
            width: 72px;
            height: 72px;
            background: linear-gradient(135deg, #3b82f6, #1e3a8a);
            border-radius: 18px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 1rem;
            box-shadow: 0 8px 20px rgba(59, 130, 246, 0.4);
        }

        .logo-icon i { color: white; font-size: 2rem; }

        .logo-area h2 {
            font-weight: 700;
            color: #1e3a8a;
            margin: 0;
        }

        .logo-area p {
            color: #64748b;
            font-size: 0.9rem;
            margin: 0;
        }

        .form-label { font-weight: 600; color: #374151; font-size: 0.875rem; }

        .form-control {
            border-radius: 10px;
            border: 1.5px solid #e5e7eb;
            padding: 0.7rem 1rem;
            font-size: 0.95rem;
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .form-control:focus {
            border-color: var(--cor-primaria);
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15);
        }

        .input-group-text {
            border-radius: 10px 0 0 10px;
            border: 1.5px solid #e5e7eb;
            border-right: none;
            background: #f8fafc;
            color: #9ca3af;
        }

        .input-group .form-control { border-radius: 0 10px 10px 0; }

        .btn-login {
            background: linear-gradient(135deg, #3b82f6, #1e3a8a);
            border: none;
            border-radius: 10px;
            padding: 0.8rem;
            font-size: 1rem;
            font-weight: 600;
            letter-spacing: 0.5px;
            transition: transform 0.15s, box-shadow 0.15s;
            box-shadow: 0 4px 15px rgba(59, 130, 246, 0.4);
        }

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(59, 130, 246, 0.5);
        }

        .alert-erro {
            background: #fef2f2;
            border: 1px solid #fecaca;
            color: #dc2626;
            border-radius: 10px;
            padding: 0.75rem 1rem;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>

<div class="card-login">
    <div class="logo-area">
        <div class="logo-icon"><i class="bi bi-house-heart-fill"></i></div>
        <h2>CrechePet</h2>
        <p>Sistema de Gerenciamento</p>
    </div>

    <%-- Exibe mensagem de erro se houver --%>
    <% if (request.getAttribute("erro") != null) { %>
    <div class="alert-erro mb-3">
        <i class="bi bi-exclamation-circle me-2"></i><%= request.getAttribute("erro") %>
    </div>
    <% } %>

    <form method="POST" action="${pageContext.request.contextPath}/login" novalidate>
        <div class="mb-3">
            <label for="email" class="form-label">E-mail</label>
            <div class="input-group">
                <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                <input type="email" id="email" name="email" class="form-control"
                       placeholder="seu@email.com" required
                       value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>"/>
            </div>
        </div>

        <div class="mb-4">
            <label for="senha" class="form-label">Senha</label>
            <div class="input-group">
                <span class="input-group-text"><i class="bi bi-lock"></i></span>
                <input type="password" id="senha" name="senha" class="form-control"
                       placeholder="••••••••" required/>
            </div>
        </div>

        <button type="submit" class="btn btn-primary btn-login w-100">
            <i class="bi bi-box-arrow-in-right me-2"></i>Entrar
        </button>
    </form>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
