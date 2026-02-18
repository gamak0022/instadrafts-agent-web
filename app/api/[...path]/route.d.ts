import { NextRequest, NextResponse } from 'next/server';
declare function handle(req: NextRequest, { params }: {
    params: Promise<{
        path: string[];
    }>;
}): Promise<NextResponse<unknown>>;
export declare const GET: typeof handle;
export declare const POST: typeof handle;
export declare const PUT: typeof handle;
export declare const PATCH: typeof handle;
export declare const DELETE: typeof handle;
export {};
