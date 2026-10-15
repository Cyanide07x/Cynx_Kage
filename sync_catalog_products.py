
import firebase_admin
from firebase_admin import credentials, firestore

KEY_PATH = r"D:\FirebaseKeys\cynx-kage-admin.json"
PROJECT_ID = "cynx-kage"

if not firebase_admin._apps:
    cred = credentials.Certificate(KEY_PATH)
    firebase_admin.initialize_app(cred, {"projectId": PROJECT_ID})

db = firestore.client()




def collect_products(collection_ref, products):
    """Recursively traverse every document and nested subcollection."""
    for document in collection_ref.list_documents():
        snapshot = document.get()
        data = snapshot.to_dict() or {}

        print("SCANNING:", document.path)

        if all(field in data for field in ("name", "price", "imageUrl")):
            if document.id in products:
                previous_path = products[document.id]["sourcePath"]
                raise ValueError(
                    f"Duplicate product ID '{document.id}':\n"
                    f"  {previous_path}\n"
                    f"  {document.path}\n"
                    "No catalog changes have been made. "
                    "Give these products unique document IDs first."
                )

            data["sourcePath"] = document.path
            products[document.id] = data

        for subcollection in document.collections():
            print("DESCENDING INTO:", subcollection.id)
            collect_products(subcollection, products)




def commit_operations(operations):
    """Commit writes/deletes in safe batches below Firestore's limit."""
    for start in range(0, len(operations), 400):
        batch = db.batch()
        for operation, reference, data in operations[start:start + 400]:
            if operation == "set":
                batch.set(reference, data)
            else:
                batch.delete(reference)
        batch.commit()


def main():
    print(f"Syncing products from Firebase project: {PROJECT_ID}")
    confirm = input(
        "This will update catalogProducts and delete stale synced entries. "
        "Type SYNC to continue: "
    ).strip()

    if confirm != "SYNC":
        print("Cancelled. No catalog changes made.")
        return

    # Collect everything first, so duplicate IDs stop the sync before writes.
    products = {}
    collect_products(db.collection("products"), products)

    source_paths = {data["sourcePath"] for data in products.values()}

    operations = []

    # Add new products and fully update existing synced product documents.
    for product_id, data in products.items():
        target = db.collection("catalogProducts").document(product_id)
        operations.append(("set", target, data))
        print(f"Queued: {data['sourcePath']} -> {target.path}")

    # Delete only catalog entries previously synced from the source.
    for document in db.collection("catalogProducts").stream():
        data = document.to_dict() or {}
        source_path = data.get("sourcePath")

        if source_path and source_path not in source_paths:
            operations.append(("delete", document.reference, None))
            print(f"Queued deletion: {document.reference.path}")

    commit_operations(operations)

    print(f"\nSync complete.")
    print(f"Products synced: {len(products)}")
    print("Stale synced catalog entries deleted where applicable.")
    print("Nested source products were not modified.")


if __name__ == "__main__":
    main()
