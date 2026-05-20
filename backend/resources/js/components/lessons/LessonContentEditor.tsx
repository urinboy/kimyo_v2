import { useEditor, EditorContent, type Editor } from '@tiptap/react';
import StarterKit from '@tiptap/starter-kit';
import Underline from '@tiptap/extension-underline';
import Link from '@tiptap/extension-link';
import TextAlign from '@tiptap/extension-text-align';
import Placeholder from '@tiptap/extension-placeholder';
import { Color } from '@tiptap/extension-color';
import { TextStyle } from '@tiptap/extension-text-style';
import MarkdownIt from 'markdown-it';
import TurndownService from 'turndown';
import {
  Bold,
  Italic,
  Underline as UnderlineIcon,
  Strikethrough,
  Heading1,
  Heading2,
  List,
  ListOrdered,
  AlignLeft,
  AlignCenter,
  AlignRight,
  Link2,
  Undo2,
  Redo2,
  Quote,
  Code2,
  Minus,
} from 'lucide-react';
import { cn } from '@/lib/utils';

const mdIt = new MarkdownIt({ html: true, linkify: true, breaks: true });
const turndown = new TurndownService({ headingStyle: 'atx', codeBlockStyle: 'fenced' });

function markdownToHtml(markdown: string): string {
  const html = mdIt.render(markdown ?? '');
  return html.trim().length === 0 ? '<p></p>' : html;
}

function TbBtn({
  onClick,
  active,
  disabled,
  children,
  title,
}: {
  onClick: () => void;
  active?: boolean;
  disabled?: boolean;
  children: React.ReactNode;
  title: string;
}) {
  return (
    <button
      type="button"
      title={title}
      disabled={disabled}
      onMouseDown={(e) => e.preventDefault()}
      onClick={onClick}
      className={cn(
        'rounded-lg p-2 text-app-muted transition-colors',
        active
          ? 'bg-purple-500 text-white shadow-sm'
          : 'hover:bg-black/10 dark:hover:bg-white/10',
        disabled && 'pointer-events-none opacity-40',
      )}
    >
      {children}
    </button>
  );
}

function EditorToolbar({ editor }: { editor: Editor }) {
  const setLink = () => {
    const prev = editor.getAttributes('link').href as string | undefined;
    const url = window.prompt('URL', prev || 'https://');
    if (url === null) return;
    if (url === '') {
      editor.chain().focus().extendMarkRange('link').unsetLink().run();
      return;
    }
    editor.chain().focus().extendMarkRange('link').setLink({ href: url }).run();
  };

  return (
    <div
      className="flex flex-wrap items-center gap-0.5 border-b border-black/10 p-2 dark:border-white/10"
      style={{ background: 'var(--surface-card)' }}
    >
      <TbBtn title="Bold" active={editor.isActive('bold')} onClick={() => editor.chain().focus().toggleBold().run()}>
        <Bold className="h-4 w-4" />
      </TbBtn>
      <TbBtn
        title="Italic"
        active={editor.isActive('italic')}
        onClick={() => editor.chain().focus().toggleItalic().run()}
      >
        <Italic className="h-4 w-4" />
      </TbBtn>
      <TbBtn
        title="Underline"
        active={editor.isActive('underline')}
        onClick={() => editor.chain().focus().toggleUnderline().run()}
      >
        <UnderlineIcon className="h-4 w-4" />
      </TbBtn>
      <TbBtn
        title="Strikethrough"
        active={editor.isActive('strike')}
        onClick={() => editor.chain().focus().toggleStrike().run()}
      >
        <Strikethrough className="h-4 w-4" />
      </TbBtn>
      <span className="mx-1 w-px self-stretch bg-black/10 dark:bg-white/15" aria-hidden />
      <TbBtn title="H1" active={editor.isActive('heading', { level: 1 })} onClick={() => editor.chain().focus().toggleHeading({ level: 1 }).run()}>
        <Heading1 className="h-4 w-4" />
      </TbBtn>
      <TbBtn title="H2" active={editor.isActive('heading', { level: 2 })} onClick={() => editor.chain().focus().toggleHeading({ level: 2 }).run()}>
        <Heading2 className="h-4 w-4" />
      </TbBtn>
      <span className="mx-1 w-px self-stretch bg-black/10 dark:bg-white/15" aria-hidden />
      <TbBtn title="Bullet list" active={editor.isActive('bulletList')} onClick={() => editor.chain().focus().toggleBulletList().run()}>
        <List className="h-4 w-4" />
      </TbBtn>
      <TbBtn
        title="Ordered list"
        active={editor.isActive('orderedList')}
        onClick={() => editor.chain().focus().toggleOrderedList().run()}
      >
        <ListOrdered className="h-4 w-4" />
      </TbBtn>
      <TbBtn title="Quote" active={editor.isActive('blockquote')} onClick={() => editor.chain().focus().toggleBlockquote().run()}>
        <Quote className="h-4 w-4" />
      </TbBtn>
      <TbBtn title="Code block" active={editor.isActive('codeBlock')} onClick={() => editor.chain().focus().toggleCodeBlock().run()}>
        <Code2 className="h-4 w-4" />
      </TbBtn>
      <TbBtn title="Horizontal line" onClick={() => editor.chain().focus().setHorizontalRule().run()}>
        <Minus className="h-4 w-4" />
      </TbBtn>
      <span className="mx-1 w-px self-stretch bg-black/10 dark:bg-white/15" aria-hidden />
      <TbBtn title="Align left" active={editor.isActive({ textAlign: 'left' })} onClick={() => editor.chain().focus().setTextAlign('left').run()}>
        <AlignLeft className="h-4 w-4" />
      </TbBtn>
      <TbBtn
        title="Align center"
        active={editor.isActive({ textAlign: 'center' })}
        onClick={() => editor.chain().focus().setTextAlign('center').run()}
      >
        <AlignCenter className="h-4 w-4" />
      </TbBtn>
      <TbBtn
        title="Align right"
        active={editor.isActive({ textAlign: 'right' })}
        onClick={() => editor.chain().focus().setTextAlign('right').run()}
      >
        <AlignRight className="h-4 w-4" />
      </TbBtn>
      <span className="mx-1 w-px self-stretch bg-black/10 dark:bg-white/15" aria-hidden />
      <TbBtn title="Link" active={editor.isActive('link')} onClick={setLink}>
        <Link2 className="h-4 w-4" />
      </TbBtn>
      {(['#7c3aed', '#dc2626', '#16a34a', '#0f172a'] as const).map((c) => (
        <button
          key={c}
          type="button"
          title={`Color ${c}`}
          className="ml-0.5 h-6 w-6 shrink-0 rounded-md border border-black/10 dark:border-white/20"
          style={{ background: c }}
          onMouseDown={(e) => e.preventDefault()}
          onClick={() => editor.chain().focus().setColor(c).run()}
        />
      ))}
      <button
        type="button"
        title="Reset color"
        className="ml-1 rounded-md border border-black/10 px-2 py-1 text-[10px] font-bold text-app-muted dark:border-white/20"
        onMouseDown={(e) => e.preventDefault()}
        onClick={() => editor.chain().focus().unsetColor().run()}
      >
        A
      </button>
      <span className="mx-1 w-px self-stretch bg-black/10 dark:bg-white/15" aria-hidden />
      <TbBtn title="Undo" onClick={() => editor.chain().focus().undo().run()} disabled={!editor.can().undo()}>
        <Undo2 className="h-4 w-4" />
      </TbBtn>
      <TbBtn title="Redo" onClick={() => editor.chain().focus().redo().run()} disabled={!editor.can().redo()}>
        <Redo2 className="h-4 w-4" />
      </TbBtn>
    </div>
  );
}

export interface LessonContentEditorProps {
  /** lessonId-langId — tab yoki dars o‘zgarganda editor qayta yuklanadi */
  resetKey: string;
  value: string;
  onChange: (markdown: string) => void;
  placeholder?: string;
}

export function LessonContentEditor({ resetKey, value, onChange, placeholder }: LessonContentEditorProps) {
  const editor = useEditor(
    {
      immediatelyRender: false,
      extensions: [
        StarterKit.configure({
          heading: { levels: [1, 2, 3] },
          // StarterKit allaqachon Link va Underline ni qo‘shadi — qayta qo‘shmaslik.
          link: false,
          underline: false,
        }),
        Underline,
        Link.configure({ openOnClick: false, autolink: true, defaultProtocol: 'https' }),
        TextAlign.configure({ types: ['heading', 'paragraph'] }),
        TextStyle,
        Color,
        Placeholder.configure({ placeholder: placeholder || '' }),
      ],
      content: markdownToHtml(value),
      onUpdate: ({ editor: ed }) => {
        onChange(turndown.turndown(ed.getHTML()));
      },
      editorProps: {
        attributes: {
          class:
            'lesson-tiptap-editor max-w-none min-h-[280px] px-3 py-3 text-sm leading-relaxed text-app-primary focus:outline-none',
        },
      },
    },
    [resetKey],
  );

  if (!editor) {
    return <div className="min-h-[320px] animate-pulse rounded-xl border border-black/10 dark:border-white/10 bg-black/[0.04] dark:bg-white/5" />;
  }

  return (
    <div className="lesson-rich-editor overflow-hidden rounded-xl border border-black/10 dark:border-white/10">
      <EditorToolbar editor={editor} />
      <EditorContent editor={editor} className="bg-black/[0.02] dark:bg-white/5" />
    </div>
  );
}
