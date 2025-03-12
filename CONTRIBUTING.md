# :scroll: Contributing to Broadcast Utilities

## :rocket: Who Can Contribute?

All contributions are **restricted** to employees, contractors, and interns working with **Broadcast Utilities**. External contributors are **not permitted** to submit changes.

---

## :open_file_folder: Branching Strategy

* **`main`** → Default branch. All feature branches must be merged into `main` via Merge Requests (MRs).

### **Branch Naming Format**

`<issue-number>/<issue-title>`

**Examples:**

```
4/add-contributing-md
23/fix-bash-script-error
```

## :twisted_rightwards_arrows: Merge Requests

:green_heart: **All contributions must go through a Merge Request (MR).**\
:green_heart: **Approvals are required before merging.**

**Reviewer:** :trophy: **Rik Visser** reviews all Merge Requests. Changes will only be merged after approval.

## :scroll: Code Standards & Documentation

All Bash scripts and code must follow the **standard Bash style guide**. Additionally:\
:green_heart: **Ensure proper documentation updates for all changes**\
:green_heart: **Follow best practices for Bash scripting and maintain readability**

## :tools: Automated CI/CD & Testing

All contributions must pass **GitLab CI/CD** validation before they can be merged. This includes:\
:green_heart: **Linting & style checks**\
:green_heart: **Unit tests (if applicable)**\
:green_heart: **Security checks (code scanning & static analysis)**

## :lock: Security & Confidentiality

:closed_lock_with_key: **All code is strictly for internal use** or for **projects owned by Broadcast Utilities**.\
:shield: **Security scans & static analysis are required** before merging.

```
💡 How to Contribute
```

### **:one: Clone the Repository**

```
git clone <repository-url>
cd <repository-name>
```

### **:two: Create a Feature Branch Following the Correct Naming Format**

```
git checkout -b <issue-number>/<issue-title>
```

**Example:**

```
git checkout -b 4/add-contributing-md
```

### **:three: Write Clean, Well-Documented Code Following Bash Best Practices**

Ensure that all contributions adhere to the standard Bash style guide and include necessary documentation.

### **:four: Commit Your Changes**

```
git commit -m "Fix: <short-description>"
```

### **:five: Push the Branch**

```
git push origin <issue-number>/<issue-title>
```

### **:six: Open a Merge Request (MR) to `main`**

### **:seven: Wait for Review and Approval from Rik Visser**

## :telephone_receiver: Need Help?

For any questions or clarifications, contact **Rik Visser** or your project lead.

**Happy coding! :rocket:**

