    # # Ensure we cleanup any pending tasks
    # remaining_tasks = [t for t in asyncio.all_tasks() if t is not asyncio.current_task()]
    # if remaining_tasks:
    #     print(f"Cleaning up {len(remaining_tasks)} remaining tasks...")
    #     # Give remaining tasks a final chance to complete
    #     await asyncio.gather(*remaining_tasks, return_exceptions=True)