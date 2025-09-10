# Web Interface Guidelines

## Agent Responsibilities vs Human Verification

### ✅ Agent MUST Implement Automatically

1. **All Tailwind classes and ARIA attributes** shown in this guide
2. **Focus management logic** (focus traps, return focus, etc.)
3. **Form validation patterns** with proper error messages
4. **URL state management** for all stateful UI elements
5. **Loading states** with spinners and disabled states
6. **Responsive classes** using Tailwind breakpoints
7. **Character replacements** (curly quotes, ellipsis, non-breaking spaces)
8. **Error boundaries** and fallback UI

### ⚠️ Agent MUST Request Human Verification

When implementing features, add these comments for human review:

```jsx
// TODO: Human verification required
// [ ] Test keyboard navigation with Tab/Enter/Escape
// [ ] Verify screen reader announces all content correctly
// [ ] Check performance on throttled connection (3G)
// [ ] Test on actual mobile device (not just responsive mode)
// [ ] Run Lighthouse audit (target: Accessibility ≥95, Performance ≥90)
```

## Core Implementation Rules

### 1. Keyboard Navigation (Agent Implements)

**ALWAYS include these patterns:**

```jsx
// Native button elements handle Enter/Space automatically
<button
  className="focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-blue-600"
  onClick={handleClick}
>
  Click Me
</button>

// For non-button interactive elements, add keyboard support
<div
  role="button"
  tabIndex={0}
  className="focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-blue-600"
  onClick={handleClick}
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      handleClick();
    }
  }}
>
  Custom Button
</div>

// Modal with proper focus trap
function Modal({ open, onClose, children }) {
  const modalRef = useRef();
  const previousFocusRef = useRef();

  useEffect(() => {
    if (open) {
      previousFocusRef.current = document.activeElement;
      modalRef.current?.focus();

      // Focus trap implementation
      const handleKeyDown = (e) => {
        if (e.key === 'Tab') {
          const focusableElements = modalRef.current?.querySelectorAll(
            'a[href], button, textarea, input, select, [tabindex]:not([tabindex="-1"])'
          );
          const firstElement = focusableElements?.[0];
          const lastElement = focusableElements?.[focusableElements.length - 1];

          if (e.shiftKey && document.activeElement === firstElement) {
            e.preventDefault();
            lastElement?.focus();
          } else if (!e.shiftKey && document.activeElement === lastElement) {
            e.preventDefault();
            firstElement?.focus();
          }
        } else if (e.key === 'Escape') {
          onClose();
        }
      };

      document.addEventListener('keydown', handleKeyDown);
      return () => {
        document.removeEventListener('keydown', handleKeyDown);
        previousFocusRef.current?.focus();
      };
    }
  }, [open, onClose]);

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 bg-black/50">
      <div
        ref={modalRef}
        role="dialog"
        aria-modal="true"
        tabIndex={-1}
        className="bg-white rounded-lg p-6"
      >
        {children}
      </div>
    </div>
  );
}
```

### 2. Interaction Patterns (Agent Implements)

**Additional required interaction patterns:**

```jsx
// Match visual & hit targets (minimum 24px, 44px on mobile) using pseudo element
const Button = ({ children, ...props }) => {
  return (
    <button
      className="relative isolate z-20 after:content-[''] after:absolute after:-inset-y-2 after:-inset-x-4 touch-action-manipulation"
      {...props}
    >
      {children}
    </button>
  );
};

// Mobile input size (prevent iOS zoom)
<input
  type="email"
  className="text-base md:text-sm" // 16px on mobile, smaller on desktop
  // OR use viewport meta tag:
  // <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, viewport-fit=cover" />
/>

// Respect zoom - NEVER disable it
// ❌ WRONG: user-scalable=no
// ✅ RIGHT: Let users zoom freely

// Ellipsis for menu items that open dialogs
<MenuItem onClick={openRenameDialog}>
  Rename… {/* Ellipsis indicates further input required */}
</MenuItem>

// Confirm destructive actions
const DeleteButton = ({ onDelete }) => {
  const [showConfirm, setShowConfirm] = useState(false);

  if (showConfirm) {
    return (
      <div className="flex gap-2">
        <button
          onClick={() => {
            onDelete();
            setShowConfirm(false);
          }}
          className="bg-red-600 text-white px-3 py-1 rounded"
        >
          Confirm Delete
        </button>
        <button
          onClick={() => setShowConfirm(false)}
          className="bg-gray-200 px-3 py-1 rounded"
        >
          Cancel
        </button>
      </div>
    );
  }

  return (
    <button
      onClick={() => setShowConfirm(true)}
      className="text-red-600"
    >
      Delete
    </button>
  );
};

// Prevent double-tap zoom on controls
<button className="touch-action-manipulation">
  Click Me
</button>

// Tap highlight follows design
<button
  style={{ WebkitTapHighlightColor: 'rgba(0, 0, 0, 0.1)' }}
  className="bg-blue-600"
>
  Tap Me
</button>

// Overscroll behavior for modals/drawers
<div className="modal overflow-y-auto overscroll-contain">
  {/* Prevents scrolling the background when reaching the end */}
</div>

// Clean drag interactions
const DraggableItem = ({ children }) => {
  const [isDragging, setIsDragging] = useState(false);

  return (
    <div
      draggable
      onDragStart={(e) => {
        setIsDragging(true);
        // Disable text selection during drag
        document.body.style.userSelect = 'none';
        // Make other elements inert
        document.querySelectorAll('.droppable').forEach(el => {
          el.setAttribute('inert', '');
        });
      }}
      onDragEnd={() => {
        setIsDragging(false);
        document.body.style.userSelect = '';
        document.querySelectorAll('.droppable').forEach(el => {
          el.removeAttribute('inert');
        });
      }}
      className={isDragging ? 'opacity-50' : ''}
    >
      {children}
    </div>
  );
};
```

### 3. Accessibility Attributes (Agent Implements)

**NEVER omit these attributes:**

```jsx
// Every form input MUST have:
<label htmlFor="email-input" className="block text-sm font-medium">
  Email Address
</label>
<input
  id="email-input"
  name="email"
  type="email"
  inputMode="email"
  autoComplete="email"
  aria-required="true"
  aria-invalid={!!errors.email}
  aria-describedby={errors.email ? "email-error" : "email-hint"}
  className="mt-1 block w-full rounded-md border-gray-300"
/>
{errors.email && (
  <p id="email-error" role="alert" className="mt-2 text-sm text-red-600">
    {errors.email}
  </p>
)}
<p id="email-hint" className="mt-2 text-sm text-gray-500">
  We'll never share your email.
</p>

// Icon buttons MUST have labels:
<button aria-label="Delete item" className="p-2">
  <TrashIcon className="h-5 w-5" aria-hidden="true" />
</button>

// Status changes MUST be announced:
<div role="status" aria-live="polite" aria-atomic="true">
  {isSaving && "Saving..."}
  {isSaved && "Saved successfully"}
</div>
```

### 4. Performance Patterns (Agent Implements)

**ALWAYS apply these optimizations:**

```jsx
// Use useDeferredValue for search/filter input (React 18+)
import { useState, useDeferredValue, useMemo, useEffect } from 'react';

const SearchInput = () => {
  const [query, setQuery] = useState('');
  const deferredQuery = useDeferredValue(query);

  // The deferred value updates with a delay, preventing expensive operations on every keystroke
  const searchResults = useMemo(() => {
    if (!deferredQuery) return [];

    // Remind human to verify performance
    console.log('TODO: Verify search completes in <500ms');

    // Expensive search operation happens here
    // This only runs when deferredQuery updates (not on every keystroke)
    return performSearch(deferredQuery);
  }, [deferredQuery]);

  // Show loading state when input is ahead of deferred value
  const isStale = query !== deferredQuery;

  return (
    <div>
      <input
        type="search"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        className="w-full px-3 py-2 border rounded-lg"
        placeholder="Search..."
      />
      {isStale && (
        <div className="text-sm text-gray-500 mt-1">Searching...</div>
      )}
      <div className="mt-4">
        {searchResults.map((result) => (
          <div key={result.id}>{result.name}</div>
        ))}
      </div>
    </div>
  );
};

// Alternative: useTransition for non-urgent updates
import { useTransition, startTransition } from 'react';

const FilterComponent = () => {
  const [filters, setFilters] = useState({});
  const [isPending, startTransition] = useTransition();

  const handleFilterChange = (newFilters) => {
    // Mark the state update as non-urgent
    startTransition(() => {
      setFilters(newFilters);
    });
  };

  return <div className={isPending ? 'opacity-50' : ''}>{/* Filter UI */}</div>;
};

// Virtualize lists > 100 items using virtua (required)
// Install: npm install virtua
import { VList } from 'virtua';

const LargeList = ({ items }) => {
  // For lists with 100 or fewer items, use regular rendering
  if (items.length <= 100) {
    return (
      <ul className="space-y-2">
        {items.map((item) => (
          <li key={item.id} className="p-2 border rounded">
            {item.name}
          </li>
        ))}
      </ul>
    );
  }

  // For 100+ items, use virtua for virtualization
  return (
    <VList style={{ height: '400px' }} className="overflow-auto">
      {items.map((item) => (
        <div key={item.id} className="p-2 border-b">
          {item.name}
        </div>
      ))}
    </VList>
  );
};

// Advanced virtua example with dynamic heights
import { VList, VListHandle } from 'virtua';

const AdvancedList = ({ items }) => {
  const listRef = useRef < VListHandle > null;

  // Scroll to top programmatically
  const scrollToTop = () => {
    listRef.current?.scrollToIndex(0);
  };

  return (
    <>
      <button
        onClick={scrollToTop}
        className="mb-2 px-4 py-2 bg-blue-600 text-white rounded"
      >
        Scroll to Top
      </button>
      <VList
        ref={listRef}
        style={{ height: '600px' }}
        className="border rounded-lg"
        overscan={3} // Number of items to render outside of the visible area
      >
        {items.map((item, index) => (
          <div
            key={item.id}
            className="p-4 border-b hover:bg-gray-50"
            style={{ minHeight: item.type === 'header' ? '80px' : '60px' }}
          >
            <div className="font-medium">{item.title}</div>
            {item.description && (
              <div className="text-sm text-gray-600 mt-1">
                {item.description}
              </div>
            )}
          </div>
        ))}
      </VList>
    </>
  );
};

// Horizontal virtualization with virtua
import { VList } from 'virtua';

const HorizontalList = ({ items }) => {
  return (
    <VList horizontal style={{ height: '200px' }} className="overflow-x-auto">
      {items.map((item) => (
        <div key={item.id} className="w-48 h-full p-4 border-r">
          {item.name}
        </div>
      ))}
    </VList>
  );
};

// Image optimization (required patterns)
<img
  src={imageSrc}
  alt={imageAlt} // NEVER omit alt text
  width={800} // ALWAYS specify dimensions
  height={600}
  loading={isAboveFold ? 'eager' : 'lazy'}
  fetchPriority={isCritical ? 'high' : 'auto'}
  className="object-cover"
/>;
```

### 5. Form Patterns (Agent Implements)

**Required form implementation:**

```jsx
const Form = () => {
  const [formData, setFormData] = useState({ email: '', password: '' });
  const [errors, setErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [hasUnsavedChanges, setHasUnsavedChanges] = useState(false);

  // Form validation function
  const validateForm = (data) => {
    const errors = {};
    if (!data.email) errors.email = 'Email is required';
    if (!data.password) errors.password = 'Password is required';
    return errors;
  };

  // Generate idempotency key
  const generateIdempotencyKey = () => {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  };

  // Submit form function (placeholder)
  const submitForm = async (data, options) => {
    // API call would go here
    console.log('Submitting:', data, options);
    // Simulate API delay
    await new Promise((resolve) => setTimeout(resolve, 1000));
  };

  // Toast notifications (placeholder)
  const toast = {
    success: (msg) => console.log('Success:', msg),
    error: (msg) => console.error('Error:', msg),
  };

  // Warn before navigation (required when hasUnsavedChanges)
  useEffect(() => {
    const handleBeforeUnload = (e) => {
      if (hasUnsavedChanges && !isSubmitting) {
        e.preventDefault();
        e.returnValue =
          'You have unsaved changes. Are you sure you want to leave?';
      }
    };

    window.addEventListener('beforeunload', handleBeforeUnload);
    return () => window.removeEventListener('beforeunload', handleBeforeUnload);
  }, [hasUnsavedChanges, isSubmitting]);

  const handleSubmit = async (e) => {
    e.preventDefault();

    // Client-side validation first
    const validationErrors = validateForm(formData);
    if (Object.keys(validationErrors).length > 0) {
      setErrors(validationErrors);
      // Focus first error field
      const firstErrorField = document.querySelector('[aria-invalid="true"]');
      firstErrorField?.focus();
      return;
    }

    setIsSubmitting(true);

    try {
      // Include idempotency key (required)
      const idempotencyKey = generateIdempotencyKey();
      await submitForm(formData, { idempotencyKey });
      setHasUnsavedChanges(false);

      // Success feedback
      toast.success('Form submitted successfully');
    } catch (error) {
      // User-friendly error (required pattern)
      const ERROR_MESSAGES = {
        400: 'Please check your input and try again.',
        401: 'Please sign in to continue.',
        500: 'Something went wrong. Please try again or contact support.',
      };

      const message =
        ERROR_MESSAGES[error.status] ||
        'Something went wrong. Please try again or contact support.';
      toast.error(message);

      // Log for debugging (human should verify)
      console.error('Form submission failed:', error);
      console.log('TODO: Verify error tracking is working');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} noValidate className="space-y-6">
      <div>
        <label htmlFor="email" className="block text-sm font-medium">
          Email
        </label>
        <input
          id="email"
          type="email"
          value={formData.email}
          onChange={(e) => {
            setFormData({ ...formData, email: e.target.value });
            setHasUnsavedChanges(true);
          }}
          aria-invalid={!!errors.email}
          className="mt-1 block w-full rounded-md border-gray-300"
        />
        {errors.email && (
          <p className="mt-2 text-sm text-red-600">{errors.email}</p>
        )}
      </div>

      <button
        type="submit"
        disabled={isSubmitting}
        className="w-full flex justify-center py-2 px-4 rounded-md bg-blue-600 text-white disabled:opacity-50"
      >
        {isSubmitting ? (
          <>
            <svg
              className="animate-spin -ml-1 mr-3 h-5 w-5"
              fill="none"
              viewBox="0 0 24 24"
            >
              <circle
                className="opacity-25"
                cx="12"
                cy="12"
                r="10"
                stroke="currentColor"
                strokeWidth="4"
              />
              <path
                className="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
              />
            </svg>
            Submitting...
          </>
        ) : (
          'Submit'
        )}
      </button>
    </form>
  );
};
```

### 6. Animation Patterns (Agent Implements)

**Required animation implementations:**

```jsx
// Honor prefers-reduced-motion using Tailwind's motion-safe
<svg className="mr-3 size-5 motion-safe:animate-spin" viewBox="0 0 24 24">
  {/* Animation only runs when motion is not reduced */}
</svg>

<div className="motion-safe:transition-all motion-safe:duration-300">
  {/* Transitions only apply when motion is not reduced */}
</div>

<button className="motion-reduce:transition-none transition-all duration-200">
  {/* Explicitly remove transitions when motion is reduced */}
</button>

// CSS implementation preference
// ✅ BEST: Pure CSS animations
@keyframes slideIn {
  from { transform: translateX(-100%); }
  to { transform: translateX(0); }
}

.slide-in {
  animation: slideIn 0.3s ease-out;
}

// ✅ GOOD: Web Animations API
const animateElement = (element) => {
  element.animate(
    [{ transform: 'translateX(-100%)' }, { transform: 'translateX(0)' }],
    { duration: 300, easing: 'ease-out' }
  );
};

// ⚠️ AVOID: JavaScript libraries unless necessary
// Only use libraries like motion/framer-motion for complex animations

// Compositor-friendly properties (GPU-accelerated)
// ✅ GOOD: transform, opacity
.good-animation {
  transform: translateX(100px);
  opacity: 0.5;
}

// ❌ BAD: Properties that trigger reflow/repaint
.bad-animation {
  width: 200px; /* Triggers reflow */
  left: 100px;  /* Triggers reflow */
  background-color: red; /* Triggers repaint */
}

// Interruptible animations
const InterruptibleAnimation = () => {
  const [isAnimating, setIsAnimating] = useState(false);
  const animationRef = useRef();

  const startAnimation = () => {
    setIsAnimating(true);
    animationRef.current = element.animate(
      [{ transform: 'scale(1)' }, { transform: 'scale(1.2)' }],
      { duration: 500 }
    );
  };

  const cancelAnimation = () => {
    if (animationRef.current) {
      animationRef.current.cancel();
      setIsAnimating(false);
    }
  };

  return (
    <button
      onClick={isAnimating ? cancelAnimation : startAnimation}
      className="transform-gpu" // Hint for GPU acceleration
    >
      {isAnimating ? 'Cancel' : 'Animate'}
    </button>
  );
};

// Correct transform origin
.dropdown-menu {
  transform-origin: top right; /* Anchored to trigger button */
  animation: dropdownOpen 0.2s ease-out;
}

@keyframes dropdownOpen {
  from {
    opacity: 0;
    transform: scaleY(0.95);
  }
  to {
    opacity: 1;
    transform: scaleY(1);
  }
}

// Easing based on context
const easingPatterns = {
  // Quick, responsive UI actions
  enter: 'ease-out',     // Starting fast, ending slow
  exit: 'ease-in',       // Starting slow, ending fast
  move: 'ease-in-out',   // Smooth both ends

  // Physical movements
  bounce: 'cubic-bezier(0.68, -0.55, 0.265, 1.55)',
  spring: 'cubic-bezier(0.175, 0.885, 0.32, 1.275)',
};
```

### 7. Layout Patterns (Agent Implements)

**Required layout implementations:**

```jsx
// Optical alignment (adjust ±1px when needed)
<div className="flex items-center gap-2">
  <Icon className="w-5 h-5 -mt-px" /> {/* Optical adjustment */}
  <span>Text</span>
</div>;

// Balance contrast in icon/text lockups
const IconTextBalance = () => {
  return (
    <>
      {/* Thin icon needs adjustment next to medium text */}
      <div className="flex items-center gap-2">
        <Icon className="w-5 h-5 stroke-2" /> {/* Increased stroke */}
        <span className="font-medium">Text</span>
      </div>

      {/* Or adjust text weight to match icon */}
      <div className="flex items-center gap-2">
        <Icon className="w-5 h-5" />
        <span className="font-normal">Text</span> {/* Lighter text */}
      </div>
    </>
  );
};
```

### 8. Content Patterns (Agent Implements)

**Required content implementations:**

```jsx
// Inline help first (avoid tooltips)
<div className="space-y-2">
  <label htmlFor="api-key">API Key</label>
  <input id="api-key" type="text" />
  <p className="text-sm text-gray-600">
    Find your API key in Settings → API Keys
  </p>
  {/* ✅ Better than tooltip */}
</div>

// Stable skeletons (match final content exactly)
const Skeleton = () => {
  return (
    <div className="space-y-4">
      {/* Skeleton MUST match actual content layout */}
      <div className="h-6 w-48 bg-gray-200 rounded" /> {/* Title */}
      <div className="h-4 w-full bg-gray-200 rounded" /> {/* Line 1 */}
      <div className="h-4 w-3/4 bg-gray-200 rounded" /> {/* Line 2 */}
    </div>
  );
};

// No dead ends
const EmptyState = () => {
  return (
    <div className="text-center py-12">
      <h3>No projects yet</h3>
      <p className="text-gray-600 mt-2">Create your first project to get started</p>
      <button className="mt-4 btn-primary">
        Create Project
      </button>
      {/* Always provide next action */}
    </div>
  );
};

// Typographic quotes and special characters
const TypographicText = () => {
  // ✅ Use proper characters
  const properText = {
    quotes: '“Hello world”',        // Curly quotes
    apostrophe: "It’s working",     // Curly apostrophe
    ellipsis: 'Loading…',           // Ellipsis character
    dash: 'January–December',      // En dash for ranges
    multiplication: '10×20',        // Multiplication sign
  };

  // ❌ Avoid straight quotes and multiple periods
  const improperText = {
    quotes: '"Hello world"',       // Straight quotes
    ellipsis: 'Loading...',        // Three periods
  };

  return <div>{properText.quotes}</div>;
};

// Tabular numbers for data using Tailwind
<table className="tabular-nums">
  {/* Numbers will align properly in columns */}
</table>

<div className="font-mono">
  {/* Use monospace font for number alignment */}
</div>

// Icons have labels for screen readers
<button aria-label="Close dialog">
  <XIcon aria-hidden="true" /> {/* Hide decorative icon */}
</button>

// Anchored headings with scroll margin
.anchored-heading {
  scroll-margin-top: 80px; /* Account for fixed header */
}

// Resilient to user-generated content
const UserContent = ({ content }) => {
  return (
    <div className="
      break-words      /* Handle long words */
      overflow-hidden  /* Contain overflow */
      max-w-full      /* Prevent expansion */
    ">
      <p className="line-clamp-3"> {/* Limit lines shown */}
        {content || 'No description provided'} {/* Handle empty */}
      </p>
    </div>
  );
};

// Locale-aware formatting
const LocaleFormat = ({ date, price, number }) => {
  const locale = navigator.language || 'en-US';

  return (
    <div>
      <time>{new Intl.DateTimeFormat(locale).format(date)}</time>
      <span>{new Intl.NumberFormat(locale, {
        style: 'currency',
        currency: 'USD'
      }).format(price)}</span>
      <span>{new Intl.NumberFormat(locale).format(number)}</span>
    </div>
  );
};

// Headings hierarchy and skip link
const PageStructure = () => {
  return (
    <>
      <a href="#main-content" className="sr-only focus:not-sr-only">
        Skip to content
      </a>
      <header>
        <h1>Page Title</h1> {/* Only one h1 per page */}
      </header>
      <main id="main-content">
        <section>
          <h2>Section Title</h2> {/* Hierarchical */}
          <h3>Subsection</h3>     {/* Never skip levels */}
        </section>
      </main>
    </>
  );
};

// Non-breaking spaces for units and terms
const NonBreakingSpaces = () => {
  return (
    <>
      <span>10&nbsp;MB</span>          {/* Keep number with unit */}
      <span>⌘&nbsp;+&nbsp;K</span>       {/* Keep shortcut together */}
      <span>Vercel&nbsp;SDK</span>     {/* Keep brand names together */}
    </>
  );
};
```

### 9. Additional Form Patterns (Agent Implements)

```jsx
// Textarea with Cmd/Ctrl+Enter submission
const TextareaForm = () => {
  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && (e.metaKey || e.ctrlKey)) {
      e.preventDefault();
      handleSubmit();
    }
  };

  return (
    <textarea
      onKeyDown={handleKeyDown}
      placeholder="Type your message (Cmd+Enter to send)…"
      className="w-full p-3 rounded border"
    />
  );
};

// Spellcheck control
<input
  type="email"
  spellCheck="false" // Disable for emails
  autoCapitalize="off"
  autoCorrect="off"
/>

<input
  type="text"
  name="username"
  spellCheck="false" // Disable for usernames/codes
/>

<textarea
  spellCheck="true" // Enable for content
/>

// Placeholder patterns
<input
  type="tel"
  placeholder="+1 (123) 456-7890…" // Example format with ellipsis
/>

<input
  type="text"
  name="api_key"
  placeholder="sk-0123456789abcdef…" // Example value with ellipsis
/>

// Password managers and 2FA compatibility
<form>
  <input
    type="email"
    name="email"
    autoComplete="email"
  />
  <input
    type="password"
    name="password"
    autoComplete="current-password"
  />
  <input
    type="text"
    name="otp"
    inputMode="numeric"
    autoComplete="one-time-code"
    pattern="[0-9]{6}"
    maxLength="6"
  />
</form>
```

### 10. Additional Performance Patterns (Agent Implements)

```jsx
// Device/browser testing checklist
// TODO: Human verification required
// [ ] Test on iOS Safari with Low Power Mode enabled
// [ ] Test on macOS Safari (different from Chrome)
// [ ] Test with browser extensions disabled
// [ ] Test on real devices, not just emulators

// Minimize layout work
const BatchedUpdates = () => {
  const updateStyles = () => {
    // ❌ BAD: Causes multiple reflows
    element.style.width = '100px';
    const height = element.offsetHeight; // Forces reflow
    element.style.height = height + 'px';
    const width = element.offsetWidth; // Forces another reflow

    // ✅ GOOD: Batch reads and writes
    const measurements = {
      height: element.offsetHeight,
      width: element.offsetWidth,
    };

    // Then apply all changes at once
    element.style.cssText = `
      width: 100px;
      height: ${measurements.height}px;
    `;
  };
};
```

### 11. Theme Color (Agent Implements)

```jsx
// Browser UI matches background
// Add to document head
<meta name="theme-color" content="#000000" /> {/* Dark mode */}
<meta name="theme-color" content="#ffffff" /> {/* Light mode */}

// Or dynamically update
useEffect(() => {
  const meta = document.querySelector('meta[name="theme-color"]');
  if (meta) {
    meta.content = isDarkMode ? '#000000' : '#ffffff';
  }
}, [isDarkMode]);
```

### 12. URL State Management (Agent Implements)

**Required for ALL stateful UI using nuqs library:**

```jsx
// Install: npm install nuqs
// Setup for Next.js App Router - wrap your app with NuqsAdapter:
// app/layout.tsx:
import { NuqsAdapter } from 'nuqs/adapters/next/app';

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <NuqsAdapter>{children}</NuqsAdapter>
      </body>
    </html>
  );
}

// Then use nuqs for type-safe URL state management
import { useQueryState, useQueryStates, parseAsString, parseAsInteger, parseAsJson } from 'nuqs';

// Single parameter example
const SearchComponent = () => {
  const [search, setSearch] = useQueryState('q', parseAsString.withDefault(''));

  return (
    <input
      type="search"
      value={search}
      onChange={(e) => setSearch(e.target.value || null)} // null removes from URL
      placeholder="Search..."
      className="w-full px-3 py-2 border rounded-lg"
    />
  );
};

// Multiple parameters with different types
const Component = () => {
  // Use individual hooks for simple values
  const [activeTab, setActiveTab] = useQueryState(
    'tab',
    parseAsString.withDefault('overview')
  );

  const [currentPage, setCurrentPage] = useQueryState(
    'page',
    parseAsInteger.withDefault(1)
  );

  const [sortBy, setSortBy] = useQueryState(
    'sort',
    parseAsString.withDefault('date')
  );

  // Use parseAsJson for complex objects
  const [filters, setFilters] = useQueryState(
    'filters',
    parseAsJson<Record<string, any>>().withDefault({})
  );

  // Or use batch updates for performance
  const [urlState, setUrlState] = useQueryStates({
    tab: parseAsString.withDefault('overview'),
    page: parseAsInteger.withDefault(1),
    sort: parseAsString.withDefault('date'),
    filters: parseAsJson<Record<string, any>>().withDefault({})
  });

  // Update multiple values at once (resets page when tab/filters change)
  const handleTabChange = (newTab: string) => {
    setUrlState({
      tab: newTab,
      page: 1 // Reset to first page
    });
  };

  const handleFilterChange = (newFilters: Record<string, any>) => {
    setUrlState({
      filters: newFilters,
      page: 1 // Reset to first page
    });
  };

  return (
    <>
      <Tabs
        value={activeTab}
        onChange={(tab) => {
          setActiveTab(tab);
          setCurrentPage(1); // Reset page on tab change
        }}
      />
      <Filters
        value={filters}
        onChange={(filters) => {
          setFilters(filters);
          setCurrentPage(1); // Reset page on filter change
        }}
      />
      <Pagination
        page={currentPage}
        onChange={setCurrentPage}
      />
    </>
  );
};

// Advanced: Custom parser with validation
import { createParser } from 'nuqs';

const statusParser = createParser({
  parse: (value) => {
    const validStatuses = ['active', 'inactive', 'pending'] as const;
    if (validStatuses.includes(value as any)) {
      return value as typeof validStatuses[number];
    }
    return null;
  },
  serialize: (value) => value
}).withDefault('active');

const StatusFilter = () => {
  const [status, setStatus] = useQueryState('status', statusParser);

  return (
    <select
      value={status}
      onChange={(e) => setStatus(e.target.value)}
      className="px-3 py-2 border rounded-lg"
    >
      <option value="active">Active</option>
      <option value="inactive">Inactive</option>
      <option value="pending">Pending</option>
    </select>
  );
};

// Options for controlling navigation behavior
const ComponentWithOptions = () => {
  const [value, setValue] = useQueryState('value', parseAsString);

  // Shallow routing (no page reload)
  const handleChange = (newValue: string) => {
    setValue(newValue, { shallow: true });
  };

  // Replace history entry instead of push
  const handleReplace = (newValue: string) => {
    setValue(newValue, { history: 'replace' });
  };

  // Scroll to top after update
  const handleWithScroll = (newValue: string) => {
    setValue(newValue, { scroll: true });
  };

  return <div>{/* UI components */}</div>;
};
```

## Final Reminders for AI Agents

1. **NEVER skip accessibility attributes** - Every interactive element needs proper ARIA labels
2. **ALWAYS include keyboard support** - Native buttons handle this automatically, custom elements need handlers
3. **ALWAYS manage focus properly** - Return focus after modals close, trap focus in dialogs
4. **NEVER block user input** - Show validation feedback instead of preventing keystrokes
5. **ALWAYS use semantic HTML first** - `<button>` not `<div onClick>`, `<a>` for navigation
6. **ALWAYS handle errors gracefully** - User-friendly messages with clear next steps
7. **ALWAYS optimize images** - Set dimensions, use lazy loading, prevent layout shift
8. **ALWAYS persist state in URL** - Every filter, tab, modal state should be in the URL
9. **ALWAYS add loading states** - Show spinners, disable buttons during submission
10. **ALWAYS request human testing** - Add TODO comments for manual verification

**Remember:** These guidelines ensure accessible, performant, and user-friendly interfaces. They are requirements, not suggestions. When in doubt, err on the side of accessibility and user experience.
