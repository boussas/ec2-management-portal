# EC2 Management Portal

A simple interactive **Bash CLI tool** to manage AWS EC2 instances using the AWS CLI.  
It provides a convenient menu-driven interface to list, start, stop, reboot, view details, terminate instances, and check their health status.

---

## Features

- List all EC2 instances in a given AWS region (with names and states)
- Start instances
- Stop instances
- Reboot an instance
- View detailed instance information in a table format
- Terminate an instance
- Check instance health status (system, instance, and reachability)
---

## Prerequisites

- **AWS CLI** installed and configured with appropriate credentials and permissions.
- **Bash** shell environment.
- IAM permissions required for the actions used by the script (see below).
---

## Required IAM Permissions

Ensure your IAM user or role has the following permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeTags"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:RebootInstances",
        "ec2:TerminateInstances"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## Usage

1. Clone or download this repository.
2. Ensure the script is executable:

   ```bash
   chmod +x ec2-portal.sh
   ```

3. Run the script:

   ```bash
   ./ec2-portal.sh
   ```

4. Follow the interactive menu to manage your EC2 instances.

---

## Configuration

- The script defaults to the AWS region `us-east-1`. To change it, modify the `REGION` variable near the top of the script.

---

## Example Output

Main menu:

<img src="https://github.com/user-attachments/assets/d074e277-4614-43e2-80e0-9e5368a3ac25" width="800" height="500" />

Option 1:

<img src="https://github.com/user-attachments/assets/e9179c95-ce98-4446-a5b1-b279f56f6d4a" width="800" height="500" />

Option 3:

<img src="https://github.com/user-attachments/assets/63574794-dda7-4a7c-82d9-00b781c7a1bc" width="800" height="500" />

Option 6:

<img src="https://github.com/user-attachments/assets/a44e98ca-86ec-4de1-87c0-e93880fdd675" width="800" height="500" />

Option 7:

<img src="https://github.com/user-attachments/assets/0808f20a-1352-4456-9aec-6ee5f6a0cc0a" width="800" height="500" />

Option 5:

<img src="https://github.com/user-attachments/assets/32263fec-cb1d-4772-a44c-364e68a0d4d5" width="800" height="500" />


---

## Notes

- Terminating an instance is permanent and cannot be undone.
- The script requires AWS CLI configured with credentials that have the necessary permissions.
---


## Author

Developed by **Mohamed Boussas**

GitHub: [@boussas](https://github.com/boussas)

---

If you have questions or feature requests, please open an issue or contact me.
