// supabase/functions/_shared/fcm.ts
// Placeholder for FCM Dispatch

export async function getFCMAccessToken(): Promise<string> {
  return "PLACEHOLDER_TOKEN_UNTIL_PROMPT_07";
}

export async function dispatchToUser(
  supabase: any,
  userId: string,
  title: string,
  body: string,
  data?: Record<string, string>
): Promise<void> {
  console.log(`[FCM MOCK] Dispatching to ${userId}: ${title} - ${body}`);
  // Database logging will be implemented later.
}
