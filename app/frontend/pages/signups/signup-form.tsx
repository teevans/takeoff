import {Button} from "@/components/ui/button"
import {
    Card,
    CardContent,
    CardDescription,
    CardHeader,
    CardTitle,
} from "@/components/ui/card"
import {
    Field,
    FieldDescription,
    FieldError,
    FieldGroup,
    FieldLabel,
} from "@/components/ui/field"
import {Input} from "@/components/ui/input"
import {Spinner} from "@/components/ui/spinner.tsx";
import {Form} from "@inertiajs/react";

export function SignupForm({...props}: React.ComponentProps<typeof Card>) {
    return (
        <Card {...props}>
            <CardHeader>
                <CardTitle>Create an account</CardTitle>
                <CardDescription>
                    Enter your email to get started with a magic link
                </CardDescription>
            </CardHeader>
            <CardContent>
                <Form action="/signups" method="post">
                    {({processing, errors}) => (

                        <FieldGroup>
                            <Field data-invalid={!!errors.name}>
                                <FieldLabel htmlFor="name">Full Name</FieldLabel>
                                <Input
                                    id="name"
                                    name="name"
                                    type="text"
                                    placeholder="John Doe"
                                    aria-invalid={!!errors.name}
                                    required
                                />
                                {errors.name && (
                                    <FieldError>{errors.name}</FieldError>
                                )}
                            </Field>
                            <Field data-invalid={!!errors.email_address}>
                                <FieldLabel htmlFor="email_address">Email</FieldLabel>
                                <Input
                                    id="email_address"
                                    name="email_address"
                                    type="email"
                                    placeholder="m@example.com"
                                    aria-invalid={!!errors.email_address}
                                    required
                                />
                                {!errors.email_address && (
                                    <FieldDescription>
                                        We&apos;ll send you a magic link to verify your email address.
                                    </FieldDescription>
                                )}
                                {errors.email_address && (
                                    <FieldError>{errors.email_address}</FieldError>
                                )}
                            </Field>
                            <FieldGroup>
                                <Field>
                                    <Button type="submit" disabled={processing}>
                                        {processing && <Spinner/>}
                                        Create Account
                                    </Button>
                                    <FieldDescription className="px-6 text-center">
                                        Already have an account? <a href="/session/new">Sign in</a>
                                    </FieldDescription>
                                </Field>
                            </FieldGroup>
                        </FieldGroup>
                    )}
                </Form>
            </CardContent>
        </Card>
    )
}
