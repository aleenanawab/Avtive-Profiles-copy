'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Loader2, X, ArrowRight } from 'lucide-react';
import { sanitizeReturnUrl, resolveReturnUrlForExistingUser } from '@/lib/utils';

import { GoogleIcon, LinkedInIcon, GitHubIcon, FacebookIcon } from '@/components/BrandIcons';
export { GoogleIcon, LinkedInIcon, GitHubIcon, FacebookIcon };

export type SocialProvider = 'google' | 'linkedin' | 'github' | 'facebook';

interface SocialAuthOptionsProps {
  onSuccess?: () => void;
  onError?: (err: string) => void;
}

export function SocialAuthOptions({ onSuccess, onError }: SocialAuthOptionsProps) {
  const router = useRouter();
  const [activeProvider, setActiveProvider] = useState<SocialProvider | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [customEmail, setCustomEmail] = useState('');
  const [customName, setCustomName] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSocialAuth = async (provider: SocialProvider, email?: string, name?: string) => {
    setIsLoading(true);
    try {
      const res = await fetch('/api/auth/social', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ provider, email, name })
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || `Failed to authenticate with ${provider}.`);
      }

      setIsModalOpen(false);
      if (onSuccess) onSuccess();

      const rawReturnUrl = typeof window !== 'undefined' ? new URLSearchParams(window.location.search).get('returnUrl') : null;
      const returnUrl = sanitizeReturnUrl(rawReturnUrl, null);

      if (data.hasProfile && (data.profileSlug || data.user?.id)) {
        // EXISTING SOCIAL USER -> Direct to their own profile in VIEW MODE
        const targetSlug = data.profileSlug || data.user?.id;
        const userProfileUrl = `/profile/${targetSlug}`;
        const destination = resolveReturnUrlForExistingUser(returnUrl, userProfileUrl);
        router.push(destination);
      } else {
        // NEW SOCIAL USER -> Must complete Role -> Theme/Skip -> Existing Editor
        try {
          localStorage.removeItem('avtive_last_saved_profile');
          sessionStorage.removeItem('avtive_open_edit_mode');
        } catch {}
        router.push('/onboarding/role');
      }
      router.refresh();
    } catch (err: any) {
      console.error(err);
      if (onError) onError(err.message || 'Social login failed. Please try again.');
    } finally {
      setIsLoading(false);
      setActiveProvider(null);
    }
  };

  const openAccountPrompt = (provider: SocialProvider) => {
    setActiveProvider(provider);
    if (provider === 'google') {
      setCustomEmail('aleenaknawab@gmail.com');
      setCustomName('Aleena Nawab');
    } else if (provider === 'linkedin') {
      setCustomEmail('aleena.nawab@linkedin.com');
      setCustomName('Aleena Nawab');
    } else if (provider === 'github') {
      setCustomEmail('aleena.dev@github.com');
      setCustomName('Aleena Developer');
    } else if (provider === 'facebook') {
      setCustomEmail('aleena.social@facebook.com');
      setCustomName('Aleena Nawab');
    }
    setIsModalOpen(true);
  };

  return (
    <div className="space-y-3 w-full">
      {/* Social Buttons: Google, LinkedIn, GitHub, Facebook */}
      <div className="grid grid-cols-2 gap-2">
        {/* Google */}
        <button
          type="button"
          onClick={() => openAccountPrompt('google')}
          disabled={isLoading}
          className="flex items-center justify-center gap-2 py-2.5 px-3 rounded-xl bg-white hover:bg-slate-50 dark:bg-[#121216] dark:hover:bg-[#1A1A22] border border-slate-200 dark:border-white/10 text-slate-800 dark:text-white text-xs font-bold shadow-2xs transition-all active:scale-[0.98] disabled:opacity-50"
        >
          {isLoading && activeProvider === 'google' ? (
            <Loader2 className="w-4 h-4 animate-spin text-slate-600 dark:text-slate-300" />
          ) : (
            <GoogleIcon className="w-4 h-4 shrink-0" />
          )}
          <span>Google</span>
        </button>

        {/* LinkedIn */}
        <button
          type="button"
          onClick={() => openAccountPrompt('linkedin')}
          disabled={isLoading}
          className="flex items-center justify-center gap-2 py-2.5 px-3 rounded-xl bg-white hover:bg-slate-50 dark:bg-[#121216] dark:hover:bg-[#1A1A22] border border-slate-200 dark:border-white/10 text-slate-800 dark:text-white text-xs font-bold shadow-2xs transition-all active:scale-[0.98] disabled:opacity-50"
        >
          {isLoading && activeProvider === 'linkedin' ? (
            <Loader2 className="w-4 h-4 animate-spin text-slate-600 dark:text-slate-300" />
          ) : (
            <LinkedInIcon className="w-4 h-4 shrink-0" />
          )}
          <span>LinkedIn</span>
        </button>

        {/* GitHub */}
        <button
          type="button"
          onClick={() => openAccountPrompt('github')}
          disabled={isLoading}
          className="flex items-center justify-center gap-2 py-2.5 px-3 rounded-xl bg-white hover:bg-slate-50 dark:bg-[#121216] dark:hover:bg-[#1A1A22] border border-slate-200 dark:border-white/10 text-slate-800 dark:text-white text-xs font-bold shadow-2xs transition-all active:scale-[0.98] disabled:opacity-50"
        >
          {isLoading && activeProvider === 'github' ? (
            <Loader2 className="w-4 h-4 animate-spin text-slate-600 dark:text-slate-300" />
          ) : (
            <GitHubIcon className="w-4 h-4 shrink-0" />
          )}
          <span>GitHub</span>
        </button>

        {/* Facebook */}
        <button
          type="button"
          onClick={() => openAccountPrompt('facebook')}
          disabled={isLoading}
          className="flex items-center justify-center gap-2 py-2.5 px-3 rounded-xl bg-white hover:bg-slate-50 dark:bg-[#121216] dark:hover:bg-[#1A1A22] border border-slate-200 dark:border-white/10 text-slate-800 dark:text-white text-xs font-bold shadow-2xs transition-all active:scale-[0.98] disabled:opacity-50"
        >
          {isLoading && activeProvider === 'facebook' ? (
            <Loader2 className="w-4 h-4 animate-spin text-slate-600 dark:text-slate-300" />
          ) : (
            <FacebookIcon className="w-4 h-4 shrink-0" />
          )}
          <span>Facebook</span>
        </button>
      </div>

      {/* Modern Divider */}
      <div className="relative flex items-center justify-center py-1">
        <div className="border-t border-slate-200 dark:border-white/10 w-full" />
        <span className="bg-white dark:bg-[#121216] px-3 text-[10px] uppercase tracking-wider text-slate-400 font-mono shrink-0">
          Or continue with email
        </span>
        <div className="border-t border-slate-200 dark:border-white/10 w-full" />
      </div>

      {/* Account Picker Modal for Social Sign In */}
      {isModalOpen && activeProvider && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-xs">
          <div className="w-full max-w-sm rounded-3xl bg-white dark:bg-[#121216] border border-slate-200 dark:border-white/15 p-6 shadow-2xl space-y-4 text-left animate-in fade-in zoom-in-95 duration-150">
            {/* Modal Header */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                {activeProvider === 'google' && <GoogleIcon className="w-5 h-5" />}
                {activeProvider === 'linkedin' && <LinkedInIcon className="w-5 h-5" />}
                {activeProvider === 'github' && <GitHubIcon className="w-5 h-5" />}
                {activeProvider === 'facebook' && <FacebookIcon className="w-5 h-5" />}
                <h3 className="text-sm font-bold text-slate-900 dark:text-white capitalize">
                  Sign in with {activeProvider}
                </h3>
              </div>
              <button
                type="button"
                onClick={() => setIsModalOpen(false)}
                className="p-1 rounded-lg text-slate-400 hover:text-slate-600 dark:hover:text-white transition-colors"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <p className="text-xs text-slate-600 dark:text-slate-400">
              Continue with your verified {activeProvider} account to instantly access your digital profile.
            </p>

            {/* Account Info Form */}
            <div className="space-y-2.5">
              <div>
                <label className="block text-[10px] font-bold uppercase tracking-wider text-slate-400 font-mono mb-1">
                  Full Name
                </label>
                <input
                  type="text"
                  value={customName}
                  onChange={(e) => setCustomName(e.target.value)}
                  placeholder="e.g. Aleena Nawab"
                  className="w-full px-3 py-2 rounded-xl text-xs font-medium border border-slate-200 dark:border-white/15 bg-slate-50 dark:bg-[#1A1A22] text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-amber-500"
                />
              </div>

              <div>
                <label className="block text-[10px] font-bold uppercase tracking-wider text-slate-400 font-mono mb-1">
                  Account Email
                </label>
                <input
                  type="email"
                  value={customEmail}
                  onChange={(e) => setCustomEmail(e.target.value)}
                  placeholder={`user@${activeProvider}.com`}
                  className="w-full px-3 py-2 rounded-xl text-xs font-medium border border-slate-200 dark:border-white/15 bg-slate-50 dark:bg-[#1A1A22] text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-amber-500"
                />
              </div>
            </div>

            {/* Actions */}
            <div className="pt-2 space-y-2">
              <button
                type="button"
                disabled={isLoading}
                onClick={() => handleSocialAuth(activeProvider, customEmail, customName)}
                className="w-full flex items-center justify-center gap-2 py-2.5 px-4 rounded-xl bg-slate-900 hover:bg-black dark:bg-white dark:hover:bg-slate-100 text-white dark:text-black font-bold text-xs shadow-md transition-all active:scale-[0.98] disabled:opacity-50"
              >
                {isLoading ? (
                  <>
                    <Loader2 className="w-3.5 h-3.5 animate-spin" />
                    <span>Connecting...</span>
                  </>
                ) : (
                  <>
                    <span>Continue as {customName.split(' ')[0] || 'User'}</span>
                    <ArrowRight className="w-3.5 h-3.5" />
                  </>
                )}
              </button>

              <button
                type="button"
                disabled={isLoading}
                onClick={() => handleSocialAuth(activeProvider)}
                className="w-full py-1.5 text-[11px] font-bold text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-white transition-colors"
              >
                Or 1-Click Instant Demo Access
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
