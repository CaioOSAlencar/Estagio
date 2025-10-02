# 🚀 Guia Rápido - AWS EC2 Setup

## ⚡ Execução em 5 Passos

### 1️⃣ Criar Instâncias EC2
```bash
# No AWS Console:
- Criar 2 instâncias t2.micro (Ubuntu 22.04)
- Security Group: Portas 22, 80, 3000
- Mesmo Key Pair para ambas
- Anotar IPs públicos
```

### 2️⃣ Setup EC2-1 (ServeRest)
```bash
# Conectar via SSH
ssh -i "sua-chave.pem" ubuntu@IP-EC2-1

# Executar setup automatizado
curl -fsSL https://raw.githubusercontent.com/CaioOSAlencar/Estagio/main/scripts/setup-ec2-serverest.sh | bash

# Verificar se funcionou
curl http://localhost:3000/usuarios
```

### 3️⃣ Setup EC2-2 (Robot Framework)
```bash
# Conectar via SSH
ssh -i "sua-chave.pem" ubuntu@IP-EC2-2

# Executar setup automatizado (vai pedir IP da EC2-1)
curl -fsSL https://raw.githubusercontent.com/CaioOSAlencar/Estagio/main/scripts/setup-ec2-robot.sh | bash
```

### 4️⃣ Configurar Security Group
```bash
# No AWS Console:
EC2 → Security Groups → Seu-Security-Group
Inbound Rules → Add Rule:
- Type: Custom TCP
- Port: 3000  
- Source: 0.0.0.0/0
```

### 5️⃣ Executar Testes
```bash
# Na EC2-2:
~/run-tests.sh
```

---

## 🔧 Comandos Úteis

### EC2-1 (ServeRest):
```bash
~/check-serverest.sh     # Ver status
~/restart-serverest.sh   # Reiniciar
sudo journalctl -u serverest -f   # Ver logs
```

### EC2-2 (Robot Framework):
```bash
~/run-tests.sh           # Executar todos os testes
~/quick-test.sh          # Teste rápido
~/monitor-tests.sh       # Monitor contínuo
```

---

## 🎯 URLs de Teste

- **ServeRest**: `http://IP-EC2-1:3000`
- **Endpoint usuarios**: `http://IP-EC2-1:3000/usuarios`
- **Endpoint produtos**: `http://IP-EC2-1:3000/produtos`

---

## 🚨 Troubleshooting

### ServeRest não responde:
```bash
# Na EC2-1:
sudo systemctl status serverest
sudo systemctl restart serverest
```

### Testes falhando:
```bash
# Na EC2-2:
~/quick-test.sh  # Testar conectividade
# Verificar se IP está correto em ~/robot-config.sh
```

### Connection Refused:
- Verificar Security Group (porta 3000)
- Verificar se ServeRest está rodando
- Usar IP público correto

---

## 💡 Dicas Importantes

1. **IPs Públicos mudam** quando reinicia EC2
2. **Security Groups** são como firewall
3. **Usar sempre IP público** para comunicação entre EC2s
4. **t2.micro** é suficiente para este teste
5. **Parar instâncias** quando não usar para economizar

---

## 📊 Resultados Esperados

- ✅ **11 testes passando** no Robot Framework
- ✅ **ServeRest respondendo** na porta 3000
- ✅ **Comunicação entre EC2s** funcionando
- ✅ **Logs e monitoramento** operacionais

**🏆 Sucesso**: Arquitetura distribuída rodando na AWS! 🎉