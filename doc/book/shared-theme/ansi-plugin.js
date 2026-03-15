// ANSI to HTML converter for terminal code blocks
// Converts ANSI escape sequences to colored HTML spans
(function () {
  "use strict";

  // Map ANSI codes to CSS classes/styles
  var ansiStyles = {
    // Reset
    "0": null,
    // Bold
    "1": "font-weight:bold",
    // Italic
    "3": "font-style:italic",
    // Underline
    "4": "text-decoration:underline",
    // Standard colors (foreground)
    "30": "color:#073642", // black
    "31": "color:#dc322f", // red
    "32": "color:#859900", // green
    "33": "color:#b58900", // yellow
    "34": "color:#268bd2", // blue
    "35": "color:#d33682", // magenta
    "36": "color:#2aa198", // cyan
    "37": "color:#eee8d5", // white
    // Bright colors (foreground)
    "90": "color:#586e75", // bright black (gray)
    "91": "color:#cb4b16", // bright red
    "92": "color:#586e75", // bright green
    "93": "color:#657b83", // bright yellow
    "94": "color:#839496", // bright blue
    "95": "color:#6c71c4", // bright magenta
    "96": "color:#93a1a1", // bright cyan
    "97": "color:#fdf6e3", // bright white
  };

  function ansiToHtml(text) {
    var result = "";
    var currentStyles = [];
    var i = 0;

    while (i < text.length) {
      // Check for ESC character (0x1b)
      if (text.charCodeAt(i) === 0x1b && text[i + 1] === "[") {
        // Find the end of the escape sequence (the 'm')
        var j = i + 2;
        while (j < text.length && text[j] !== "m") {
          j++;
        }
        if (j < text.length) {
          // Extract the codes (e.g., "1;31" from ESC[1;31m)
          var codes = text.substring(i + 2, j).split(";");

          // Close any open spans for reset
          if (codes.indexOf("0") !== -1 || codes.length === 0) {
            for (var k = 0; k < currentStyles.length; k++) {
              result += "</span>";
            }
            currentStyles = [];
          }

          // Apply new styles
          var newStyles = [];
          for (var c = 0; c < codes.length; c++) {
            var code = codes[c];
            if (code === "0") continue; // reset handled above

            // Handle combined codes like "1;31" (bold red)
            var style = ansiStyles[code];
            if (style) {
              newStyles.push(style);
            }
          }

          if (newStyles.length > 0) {
            result += '<span style="' + newStyles.join(";") + '">';
            currentStyles.push(newStyles.length);
          }

          i = j + 1; // Skip past the 'm'
          continue;
        }
      }

      // Escape HTML special characters
      var char = text[i];
      if (char === "<") {
        result += "&lt;";
      } else if (char === ">") {
        result += "&gt;";
      } else if (char === "&") {
        result += "&amp;";
      } else {
        result += char;
      }
      i++;
    }

    // Close any remaining open spans
    for (var s = 0; s < currentStyles.length; s++) {
      result += "</span>";
    }

    return result;
  }

  // Process all terminal code blocks
  function processTerminalBlocks() {
    document
      .querySelectorAll("code.language-terminal, code.language-ansi")
      .forEach(function (block) {
        var text = block.textContent;
        block.innerHTML = ansiToHtml(text);
        block.classList.add("hljs"); // Add hljs class for consistent styling
      });
  }

  // Run when DOM is ready
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", processTerminalBlocks);
  } else {
    processTerminalBlocks();
  }
})();
