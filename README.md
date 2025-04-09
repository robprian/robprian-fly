# **Secure Server Deployment on Fly.io**

This server auto installed *Python3.11 + NodeJS 22.14.0 + PHP8.2.28*

## 🔧 **Deployment Steps**

### **1. Clone the repository

```bash
git clone https://github.com/robprian/robprian-fly.git
cd robprian-fly
```

---

### **2. Configure fly.toml

```bash
app = 'robprian-fly' # change with your project name
primary_region = 'cdg' #change with region you need i.e iad,lax,sin
```

---

### **3. Deploy to Fly.io

```bash
fly launch
```
```
type y  
type N  
type y
```
---

## 🛠️ **Troubleshooting**

### **Check Logs**
```bash
fly logs -a robprian-fly
```

---


## 📝 **Notes**
✅ Port 2222  
✅ SSH command : ssh -p 2222 robprian@your-ip-address  
✅ Extend volume : fly vol extend volume_xxxx --size 10gb  

If you encounter issues or have questions, feel free to ask! 🚀  
