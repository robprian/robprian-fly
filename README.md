# **Secure SSH Server Deployment on Fly.io**

This guide outlines the steps to deploy a secure SSH server on Fly.io with persistent configuration for enhanced reliability.

---

## 🚀 **Prerequisites**
Before you begin, ensure you have:

✅ A registered Fly.io account  
✅ Fly.io CLI installed (`flyctl`)  
✅ An SSH client (e.g., OpenSSH, MobaXterm)  
✅ A public SSH key (`~/.ssh/id_ed25519.pub`)  

---

## 🔧 **Deployment Steps**

### **1. Clone the repository**
Run the following command:

```bash
git clone https://github.com/robprian/robprian-fly.git
cd robprian-fly
```

---

### **2. Create New Application**
Create new Application name `robprian-fly` to Fly.io with:

```bash
fly apps create robprian-fly
```

---

### **3. Deploy the Application**
Deploy your server to Fly.io with:

```bash
fly deploy --strategy immediate --remote-only --detach
```

---

## 🔐 **Connect to Your SSH Server**

### **Standard Port (Recommended)**
```bash
ssh -p 2222 robprian@robprian-fly.fly.dev
```

### **Alternative Port**
```bash
ssh -p 2222 robprian@YOUR_IPV4_ADDRESS
```

---

## 🛠️ **Troubleshooting**

### **Check Logs**
```bash
fly logs -a robprian-fly
```

---

### **Repair or Recreate Volume**
If volume issues arise:

1. List volumes:
   ```bash
   fly volumes list -a robprian-fly
   ```

2. Delete the problematic volume:
   ```bash
   fly volumes delete <volume-id> -a robprian-fly --yes
   ```

3. Recreate the volume:
   ```bash
   fly volumes create robprian -a robprian-fly --size 1 --region cdg
   ```

---

### **Force Re-deploy**
```bash
fly deploy --strategy immediate --remote-only --detach
```

--- 

If you encounter issues or have questions, feel free to ask! 🚀
