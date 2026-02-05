import { Button } from "@/components/ui/button.tsx"
import { Spinner } from "@/components/ui/spinner.tsx"
import {
    Card,
    CardContent,
    CardDescription,
    CardHeader,
    CardTitle,
} from "@/components/ui/card.tsx"
import {
    Field,
    FieldDescription,
    FieldError,
    FieldGroup,
    FieldLabel,
} from "@/components/ui/field.tsx"
import { Input } from "@/components/ui/input.tsx"
import { Form, Link, usePage } from '@inertiajs/react'
import GuestLayout from "@/pages/layouts/guest-layout.tsx";
import { Alert, AlertDescription } from "@/components/ui/alert.tsx"
import { Code2, Mail } from "lucide-react";

function Verify() {
    const { props } = usePage()
    const pendingEmail = props.pending_email as string | undefined
    const devInfo = props.dev_info as { code?: string; url?: string } | undefined
    const urlParams = new URLSearchParams(window.location.search);
    const token = urlParams.get('token');
    
    // Log to console in development
    if (devInfo) {
        console.log('🔐 Magic Link Info:')
        console.log('Code:', devInfo.code)
        console.log('URL:', devInfo.url)
    }

    if (token) {
        return (
            <div className="flex min-h-svh w-full items-center justify-center p-6 md:p-10">
                <div className="w-full max-w-sm">
                    <Card>
                        <CardHeader>
                            <CardTitle>Verifying...</CardTitle>
                            <CardDescription>
                                We're signing you in. Please wait a moment.
                            </CardDescription>
                        </CardHeader>
                        <CardContent>
                            <div className="flex justify-center">
                                <Spinner />
                            </div>
                        </CardContent>
                    </Card>
                </div>
            </div>
        )
    }

    return (
        <div className="flex min-h-svh w-full items-center justify-center p-6 md:p-10">
            <div className="w-full max-w-sm">
                <div className="flex flex-col gap-6">
                    {devInfo && (
                        <Alert className="border-amber-200 bg-amber-50">
                            <Code2 className="h-4 w-4" />
                            <AlertDescription>
                                <div className="font-semibold mb-2">Development Mode - Magic Link Info:</div>
                                <div className="space-y-1 font-mono text-sm">
                                    <div>Code: <span className="font-bold text-lg">{devInfo.code}</span></div>
                                    <div className="break-all">
                                        URL: <a href={devInfo.url} className="text-blue-600 underline">{devInfo.url}</a>
                                    </div>
                                </div>
                            </AlertDescription>
                        </Alert>
                    )}
                    
                    {pendingEmail && (
                        <Alert>
                            <Mail className="h-4 w-4" />
                            <AlertDescription>
                                We've sent a verification code to <strong>{pendingEmail}</strong>
                            </AlertDescription>
                        </Alert>
                    )}
                    
                    <Card>
                        <CardHeader>
                            <CardTitle>Enter verification code</CardTitle>
                            <CardDescription>
                                Enter the 6-character code from your email
                            </CardDescription>
                        </CardHeader>
                    <CardContent>
                        <Form action="/session/verify" method="get">
                            {({
                                errors,
                                processing,
                            }) => (
                                <FieldGroup>
                                    {!pendingEmail && (
                                        <Field>
                                            <FieldLabel htmlFor="email_address">Email</FieldLabel>
                                            <Input
                                                id="email_address"
                                                name="email_address"
                                                type="email"
                                                placeholder="m@example.com"
                                                required
                                                tabIndex={1}
                                            />
                                            <FieldError>{errors.email_address?.message}</FieldError>
                                        </Field>
                                    )}
                                    {pendingEmail && (
                                        <input type="hidden" name="email_address" value={pendingEmail} />
                                    )}
                                    <Field>
                                        <FieldLabel htmlFor="code">Verification Code</FieldLabel>
                                        <Input
                                            id="code"
                                            name="code"
                                            type="text"
                                            placeholder="ABC123"
                                            required
                                            tabIndex={pendingEmail ? 1 : 2}
                                            autoFocus={!!pendingEmail}
                                            maxLength={6}
                                            className="uppercase tracking-widest text-center font-mono"
                                        />
                                        <FieldError>{errors.code?.message}</FieldError>
                                        <FieldDescription>
                                            Enter the 6-character code from your email
                                        </FieldDescription>
                                    </Field>
                                    <Field>
                                        <Button type="submit" tabIndex={pendingEmail ? 2 : 3} disabled={processing}>
                                            {processing && <Spinner />}
                                            Verify & Sign In
                                        </Button>
                                        <FieldDescription className="text-center">
                                            {pendingEmail ? (
                                                <span>Wrong email? <Link href="/session/new">Start over</Link></span>
                                            ) : (
                                                <Link href="/session/new">Request a new code</Link>
                                            )}
                                        </FieldDescription>
                                    </Field>
                                </FieldGroup>
                            )}
                        </Form>
                    </CardContent>
                </Card>
                </div>
            </div>
        </div>
    )
}

Verify.layout = (page: React.ReactNode) => <GuestLayout children={page}/>

export default Verify