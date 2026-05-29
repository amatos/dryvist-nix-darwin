# Raycast Configuration Module
#
# Declarative Raycast preferences managed via macOS defaults.
# These settings persist across reinstalls and database resets.
#
# Usage:
#   programs.raycast.enable = true;
#
# Note: Only preference-type settings belong here.
# Dynamic data (quicklinks, snippets, history) lives in Raycast's
# encrypted SQLite databases and should be managed via Raycast's
# export/import feature.
#
# Cloud Sync: Requires manual authentication via Raycast UI.
# After fresh install: Raycast > Settings > Account > Sign In
# Once authenticated, the sync settings below will take effect.
#
# To see all available keys: defaults read com.raycast.macos
# Reference: https://raycast.com

{ lib, config, ... }:

let
  cfg = config.programs.raycast;
in
{
  options.programs.raycast = {
    enable = lib.mkEnableOption "declarative Raycast preferences";
  };

  config = lib.mkIf cfg.enable {
    system.defaults.CustomUserPreferences = {
      "com.raycast.macos" = {
        # ========================================================================
        # Appearance
        # ========================================================================

        # Follow system dark/light mode
        # Default: true
        raycastShouldFollowSystemAppearance = true;

        # Window mode: "default" or "compact"
        raycastPreferredWindowMode = "default";

        # ========================================================================
        # Menu Bar
        # ========================================================================

        # Show hyper key icon in menu bar
        # Default: false
        useHyperKeyIcon = true;

        # ========================================================================
        # Window Behavior
        # ========================================================================

        # Keep window open when clicking away
        # Default: false
        keepWindowVisibleOnResignKey = false;

        # ========================================================================
        # Quicklinks
        # ========================================================================

        # Auto-fill links in quicklinks
        # Default: true
        quicklinks_enableAutoFillLink = true;

        # Enable quick search for quicklinks
        # Default: true
        quicklinks_enableQuickSearch = true;

        # ========================================================================
        # Screenshots
        # ========================================================================

        # Copy screenshot to clipboard
        # Default: true
        mainWindowCaptureCopyToClipboard = true;

        # Open Finder after screenshot
        # Default: false
        mainWindowCaptureShowInFinder = false;

        # Show overlay after screenshot
        # Default: false
        mainWindowCaptureOpenQuickAccessOverlay = false;

        # ========================================================================
        # Cloud Sync (Raycast Pro)
        # ========================================================================
        # Note: Sync requires manual authentication first.
        # These settings ensure sync auto-activates once logged in.

        # Enable cloud sync for presets (extensions, snippets, quicklinks)
        # Default: 1 (enabled)
        cloudSync_ensurePresetSyncRecords = 1;

        # Skip Pro plan walkthrough on fresh install
        # Value: 1 = already shown (skip), 0 = show walkthrough
        raycastAccountService_proPlanWalkthroughShownOnCurrentDevice = 1;

        # Skip cloud sync walkthrough on fresh install
        # Value: 1 = already shown (skip), 0 = show walkthrough
        raycastAccountService_cloudSyncWalkthroughShown = 1;
      };
    };
  };
}
