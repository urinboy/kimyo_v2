import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/app.css', 'resources/js/main.tsx'],
            refresh: ['resources/views/**', 'routes/**', 'resources/js/**'],
        }),
        react(),
        tailwindcss(),
    ],
    resolve: {
        alias: {
            '@': path.resolve(__dirname, 'resources/js'),
        },
    },
    server: {
        watch: {
            ignored: ['**/storage/framework/views/**'],
        },
    },
    build: {
        chunkSizeWarningLimit: 600,
        rollupOptions: {
            output: {
                manualChunks(id) {
                    if (!id.includes('node_modules')) return;
                    if (id.includes('lucide-react')) return 'icons';
                    if (id.includes('react-dom') || /[/\\]node_modules[/\\]react[/\\]/.test(id) || id.includes('scheduler')) {
                        return 'react-vendor';
                    }
                    if (id.includes('react-router')) return 'react-router';
                    if (id.includes('@tanstack')) return 'tanstack';
                    if (id.includes('i18next') || id.includes('react-i18next')) return 'i18n';
                    if (id.includes('axios')) return 'axios';
                    if (id.includes('sonner')) return 'sonner';
                    if (id.includes('zustand')) return 'zustand';
                    if (id.includes('date-fns')) return 'date-fns';
                    if (id.includes('clsx') || id.includes('tailwind-merge')) return 'util-classnames';
                },
            },
        },
    },
});
