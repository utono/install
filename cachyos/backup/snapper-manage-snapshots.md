# Managing Snapshots in Snapper

This guide covers essential Snapper commands for listing, creating, and deleting snapshots. Snapshots provide a way to track filesystem changes, enabling easy rollback when needed.

---

## **Command Summary**

| **Task**                  | **Command**                                        |
|---------------------------|----------------------------------------------------|
| List snapshots            | `snapper -c <config> list`                         |
| Create a snapshot         | `snapper -c <config> create -d "<description>"`    |
| Create a pre snapshot     | `snapper -c <config> create --pre -d "<description>"` |
| Create a post snapshot    | `snapper -c <config> create --post -d "<description>"` |
| Create a numbered snapshot | `snapper -c <config> create --type single -d "<description>"` |
| Delete a snapshot         | `snapper -c <config> delete <number>`              |
| Delete multiple snapshots | `snapper -c <config> delete <start>..<end>`        |

---

## **Listing Snapshots**

To see all snapshots for a specific configuration, use:

```bash
snapper -c <config> list
```

Replace `<config>` with your Snapper configuration name (e.g., `root`, `home`). This command displays snapshot details, including IDs, timestamps, and descriptions.

---

## **Creating Snapshots**

Snapper supports different snapshot types:

### **Standard Snapshot**
Create a basic snapshot with a description:

```bash
snapper -c <config> create -d "Manual snapshot before update"
```

### **Pre and Post Snapshots**
Pre and post snapshots help track system changes before and after an operation.

- Create a **pre snapshot** before making changes:

  ```bash
  snapper -c <config> create --pre -d "Before installing package"
  ```

- After making changes, create a **post snapshot**:

  ```bash
  snapper -c <config> create --post -d "After installing package"
  ```

If a **pre snapshot** exists, Snapper automatically links the **post snapshot**.

### **Numbered Snapshots**
To create a snapshot that Snapper manages based on retention policies:

```bash
snapper -c <config> create --type single -d "Persistent snapshot"
```

This is useful for snapshots that should be kept longer than the default cleanup settings allow.

---

## **Deleting Snapshots**

To remove a specific snapshot, use:

```bash
snapper -c <config> delete <snapshot_number>
```

For example, deleting snapshot `42`:

```bash
snapper -c root delete 42
```

### **Deleting Multiple Snapshots**
You can delete a range of snapshots in one command:

```bash
snapper -c <config> delete <start_number>..<end_number>
```

Example:

```bash
snapper -c home delete 10..20
```

This removes all snapshots from `10` to `20` in the `home` configuration.

