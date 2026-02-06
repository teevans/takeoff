import {cn} from "@/lib/utils.ts"
import {Button} from "@/components/ui/button.tsx"
import {Spinner} from "@/components/ui/spinner.tsx"
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
    FieldGroup,
    FieldLabel,
} from "@/components/ui/field.tsx"
import {Input} from "@/components/ui/input.tsx"
import {Form, Link} from '@inertiajs/react'

export function LoginForm({
                              className,
                              ...props
                          }: React.ComponentProps<"div">) {
    return (
        <div className={cn("flex flex-col gap-6", className)} {...props}>
            <Card>
                <CardHeader>
                    <CardTitle>Sign in to your account</CardTitle>
                    <CardDescription>
                        Enter your email to receive a magic link
                    </CardDescription>
                </CardHeader>
                <CardContent>
                    <Form action="/session" method="post">
                        {({
                              errors,
                              processing,
                          }) => (
                            <FieldGroup>
                                <Field>
                                    <FieldLabel htmlFor="email_address">Email</FieldLabel>
                                    <Input
                                        id="email_address"
                                        name="email_address"
                                        type="email_address"
                                        placeholder="m@example.com"
                                        required
                                        tabIndex={1}
                                        data-invalid={errors.email_address ? "true" : undefined}
                                    />
                                </Field>
                                <Field>
                                    <Button type="submit" tabIndex={2} disabled={processing}>
                                        {processing && <Spinner/>}
                                        Send Magic Link
                                    </Button>
                                    <FieldDescription className="text-center">
                                        Don&apos;t have an account? <Link href="/signups/new">Sign up</Link>
                                    </FieldDescription>
                                </Field>
                            </FieldGroup>
                        )}
                    </Form>
                </CardContent>
            </Card>
        </div>
    )
}
