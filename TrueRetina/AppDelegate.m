//
//  AppDelegate.m
//  TrueRetina
//
//  Created by Adrian Kemp on 2015-04-08.
//  Copyright (c) 2015 Adrian Kemp (http://adriankemp.com/).
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  Contributors:
//  Adrian Kemp (http://adriankemp.com/)
//

#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

CGDisplayModeRef findDisplayMode(CGFloat width, CGFloat height, CGDirectDisplayID display);

@interface AppDelegate ()

@property (nonatomic, strong) NSStatusItem *menuBarItem;
@property (nonatomic, strong) NSWindowController *resolutionSelectionWindowController;
@property (nonatomic, strong) IBOutlet NSMenu *resolutionMenu;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.menuBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];

    self.menuBarItem.image = [NSImage imageNamed:@"TrueRetina"];
    
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Retina" action:@selector(setRetina:) keyEquivalent:@""];
    [menu addItemWithTitle:@"Standard" action:@selector(setStandard:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]]; // A thin grey line
    [menu addItemWithTitle:@"Quit TrueRetina" action:@selector(terminate:) keyEquivalent:@""];
    self.menuBarItem.menu = menu;
}

- (IBAction)setRetina:(id)sender {
    CGDirectDisplayID mainDisplay = CGMainDisplayID();
    NSRect screenFrame = [NSScreen mainScreen].frame;
    CGFloat screenScale = [NSScreen mainScreen].backingScaleFactor;
    
    CGDisplayModeRef targetMode = findDisplayMode(screenFrame.size.width * screenScale, screenFrame.size.height * screenScale, mainDisplay);
    
    CGDisplayConfigRef displayConfig;
    if (CGBeginDisplayConfiguration(&displayConfig) == kCGErrorSuccess) {
        CGConfigureDisplayWithDisplayMode(displayConfig, mainDisplay, targetMode, NULL);
        CGCompleteDisplayConfiguration(displayConfig, kCGConfigureForSession);
    }
    CGDisplayModeRelease(targetMode);
}

- (IBAction)setStandard:(id)sender {
    CGRestorePermanentDisplayConfiguration();
}

@end

CGDisplayModeRef findDisplayMode(CGFloat width, CGFloat height, CGDirectDisplayID display) {
    CFArrayRef availableModes = CGDisplayCopyAllDisplayModes(display, NULL);
    
    CGDisplayModeRef targetMode = NULL;
    
    for (int i = 0; i < CFArrayGetCount(availableModes); i++) {
        CGDisplayModeRef mode = (CGDisplayModeRef)CFArrayGetValueAtIndex(availableModes, i);
        size_t displayModeHeight = CGDisplayModeGetHeight(mode);
        size_t displayModeWidth = CGDisplayModeGetWidth(mode);
        if (displayModeHeight == height && displayModeWidth == width) {
            targetMode = mode;
            break;
        }
    }
    
    if (targetMode) {
        CGDisplayModeRetain(targetMode);
    }
    CFRelease(availableModes);
    return targetMode;
}