import { router } from "@inertiajs/react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Switch } from "@/components/ui/switch"
import { Label } from "@/components/ui/label"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { AlertCircle, Bell, Mail, MessageSquare, Smartphone } from "lucide-react"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { useBreadcrumbContext } from "@/contexts/breadcrumb-context"
import { useEffect } from "react"

interface NotificationType {
    id: number
    key: string
    name: string
    description: string | null
    category: string
    channels: string[]
    default_enabled: boolean
    force_enabled: boolean
}

interface Subscription {
    id: number
    notification_type_id: number
    email_enabled: boolean
    sms_enabled: boolean
    push_enabled: boolean
}

interface Settings {
    id: number
    email_batch_minutes: number
    quiet_hours_start: string
    quiet_hours_end: string
    timezone: string
}

interface Props {
    notification_types: NotificationType[]
    subscriptions: Record<string, Subscription>
    settings: Settings
}

const categoryIcons = {
    project: <Bell className="h-4 w-4" />,
    team: <MessageSquare className="h-4 w-4" />,
    system: <AlertCircle className="h-4 w-4" />,
}

const timezones = [
    "America/New_York",
    "America/Chicago",
    "America/Denver",
    "America/Los_Angeles",
    "America/Phoenix",
    "UTC",
]

export default function NotificationSettings({ notification_types, subscriptions, settings }: Props) {
    const { setBreadcrumbs } = useBreadcrumbContext()
    
    useEffect(() => {
        setBreadcrumbs([
            { label: "Notification Settings" }
        ])
    }, [setBreadcrumbs])

    // Group notification types by category
    const groupedTypes = notification_types.reduce((acc, type) => {
        if (!acc[type.category]) {
            acc[type.category] = []
        }
        acc[type.category].push(type)
        return acc
    }, {} as Record<string, NotificationType[]>)

    const handleSubscriptionToggle = (typeId: number, channel: string, enabled: boolean) => {
        const data: any = {}
        data[`${channel}_enabled`] = enabled
        
        router.patch(`/notification_settings/${typeId}/update_subscription`, data, {
            preserveScroll: true,
        })
    }

    const handleSettingsUpdate = (field: string, value: any) => {
        const data: any = {}
        data[field] = value
        
        router.patch('/notification_settings/update_settings', data, {
            preserveScroll: true,
        })
    }

    const isSubscriptionEnabled = (typeId: number, channel: string): boolean => {
        const subscription = subscriptions[typeId.toString()]
        if (!subscription) {
            // If no subscription exists, use the default
            const type = notification_types.find(t => t.id === typeId)
            return type?.default_enabled ?? true
        }
        return subscription[`${channel}_enabled` as keyof Subscription] as boolean
    }

    return (
        <div className="space-y-6">
            <div>
                <h1 className="text-3xl font-bold">Notification Settings</h1>
                <p className="text-muted-foreground mt-2">
                    Manage how and when you receive notifications
                </p>
            </div>

            <Tabs defaultValue="subscriptions" className="space-y-4">
                <TabsList>
                    <TabsTrigger value="subscriptions">Notification Types</TabsTrigger>
                    <TabsTrigger value="delivery">Delivery Settings</TabsTrigger>
                </TabsList>

                <TabsContent value="subscriptions" className="space-y-4">
                    {Object.entries(groupedTypes).map(([category, types]) => (
                        <Card key={category}>
                            <CardHeader>
                                <CardTitle className="flex items-center gap-2">
                                    {categoryIcons[category as keyof typeof categoryIcons]}
                                    {category.charAt(0).toUpperCase() + category.slice(1)} Notifications
                                </CardTitle>
                            </CardHeader>
                            <CardContent className="space-y-4">
                                {types.map((type) => (
                                    <div key={type.id} className="space-y-3 pb-4 border-b last:border-0">
                                        <div className="flex justify-between items-start">
                                            <div className="space-y-1">
                                                <Label className="text-base">{type.name}</Label>
                                                {type.description && (
                                                    <p className="text-sm text-muted-foreground">
                                                        {type.description}
                                                    </p>
                                                )}
                                                {type.force_enabled && (
                                                    <Alert className="mt-2">
                                                        <AlertCircle className="h-4 w-4" />
                                                        <AlertDescription>
                                                            This notification cannot be disabled for security reasons.
                                                        </AlertDescription>
                                                    </Alert>
                                                )}
                                            </div>
                                        </div>
                                        
                                        {!type.force_enabled && (
                                            <div className="flex gap-6 ml-4">
                                                {type.channels.includes("email") && (
                                                    <div className="flex items-center space-x-2">
                                                        <Switch
                                                            id={`${type.id}-email`}
                                                            checked={isSubscriptionEnabled(type.id, "email")}
                                                            onCheckedChange={(checked: boolean) =>
                                                                handleSubscriptionToggle(type.id, "email", checked)
                                                            }
                                                        />
                                                        <Label 
                                                            htmlFor={`${type.id}-email`} 
                                                            className="flex items-center gap-1 cursor-pointer"
                                                        >
                                                            <Mail className="h-3 w-3" />
                                                            Email
                                                        </Label>
                                                    </div>
                                                )}
                                                
                                                {type.channels.includes("sms") && (
                                                    <div className="flex items-center space-x-2">
                                                        <Switch
                                                            id={`${type.id}-sms`}
                                                            checked={isSubscriptionEnabled(type.id, "sms")}
                                                            onCheckedChange={(checked: boolean) =>
                                                                handleSubscriptionToggle(type.id, "sms", checked)
                                                            }
                                                        />
                                                        <Label 
                                                            htmlFor={`${type.id}-sms`}
                                                            className="flex items-center gap-1 cursor-pointer"
                                                        >
                                                            <MessageSquare className="h-3 w-3" />
                                                            SMS
                                                        </Label>
                                                    </div>
                                                )}
                                                
                                                {type.channels.includes("push") && (
                                                    <div className="flex items-center space-x-2">
                                                        <Switch
                                                            id={`${type.id}-push`}
                                                            checked={isSubscriptionEnabled(type.id, "push")}
                                                            onCheckedChange={(checked: boolean) =>
                                                                handleSubscriptionToggle(type.id, "push", checked)
                                                            }
                                                        />
                                                        <Label 
                                                            htmlFor={`${type.id}-push`}
                                                            className="flex items-center gap-1 cursor-pointer"
                                                        >
                                                            <Smartphone className="h-3 w-3" />
                                                            Push
                                                        </Label>
                                                    </div>
                                                )}
                                            </div>
                                        )}
                                    </div>
                                ))}
                            </CardContent>
                        </Card>
                    ))}
                </TabsContent>

                <TabsContent value="delivery" className="space-y-4">
                    <Card>
                        <CardHeader>
                            <CardTitle>Email Delivery</CardTitle>
                            <CardDescription>
                                Configure how email notifications are delivered to you
                            </CardDescription>
                        </CardHeader>
                        <CardContent className="space-y-4">
                            <div className="space-y-2">
                                <Label htmlFor="batch-time">Batch emails every</Label>
                                <Select
                                    value={settings.email_batch_minutes.toString()}
                                    onValueChange={(value) => 
                                        handleSettingsUpdate("email_batch_minutes", parseInt(value))
                                    }
                                >
                                    <SelectTrigger id="batch-time">
                                        <SelectValue />
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="0">Immediately</SelectItem>
                                        <SelectItem value="5">5 minutes</SelectItem>
                                        <SelectItem value="15">15 minutes</SelectItem>
                                        <SelectItem value="30">30 minutes</SelectItem>
                                        <SelectItem value="60">1 hour</SelectItem>
                                    </SelectContent>
                                </Select>
                                <p className="text-sm text-muted-foreground">
                                    Group multiple notifications into a single email when possible
                                </p>
                            </div>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardHeader>
                            <CardTitle>Quiet Hours</CardTitle>
                            <CardDescription>
                                Don't send notifications during these hours (except urgent ones)
                            </CardDescription>
                        </CardHeader>
                        <CardContent className="space-y-4">
                            <div className="grid grid-cols-2 gap-4">
                                <div className="space-y-2">
                                    <Label htmlFor="quiet-start">Start time</Label>
                                    <Input
                                        id="quiet-start"
                                        type="time"
                                        value={settings.quiet_hours_start}
                                        onChange={(e) => 
                                            handleSettingsUpdate("quiet_hours_start", e.target.value)
                                        }
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label htmlFor="quiet-end">End time</Label>
                                    <Input
                                        id="quiet-end"
                                        type="time"
                                        value={settings.quiet_hours_end}
                                        onChange={(e) => 
                                            handleSettingsUpdate("quiet_hours_end", e.target.value)
                                        }
                                    />
                                </div>
                            </div>
                            
                            <div className="space-y-2">
                                <Label htmlFor="timezone">Timezone</Label>
                                <Select
                                    value={settings.timezone}
                                    onValueChange={(value) => handleSettingsUpdate("timezone", value)}
                                >
                                    <SelectTrigger id="timezone">
                                        <SelectValue />
                                    </SelectTrigger>
                                    <SelectContent>
                                        {timezones.map(tz => (
                                            <SelectItem key={tz} value={tz}>{tz}</SelectItem>
                                        ))}
                                    </SelectContent>
                                </Select>
                            </div>
                        </CardContent>
                    </Card>
                </TabsContent>
            </Tabs>
        </div>
    )
}